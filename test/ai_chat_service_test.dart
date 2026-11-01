import 'dart:convert';

import 'package:busypro_max/models/demo_thread.dart';
import 'package:busypro_max/services/ai_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  DemoThread sampleThread() => DemoThread(
    id: 'direct-maya',
    name: 'Maya Chen',
    initials: 'MC',
    channel: DemoChannel.direct,
    messages: <DemoMessage>[
      DemoMessage(
        text: 'are you free?',
        isMine: true,
        sentAt: DateTime(2026, 10, 28, 12),
      ),
      DemoMessage(
        text: 'yeah, library steps',
        isMine: false,
        sentAt: DateTime(2026, 10, 28, 12, 1),
      ),
    ],
  );

  http.Response completion(String content) => http.Response(
    jsonEncode(<String, dynamic>{
      'choices': <Map<String, dynamic>>[
        <String, dynamic>{
          'message': <String, String>{'content': content},
        },
      ],
    }),
    200,
    headers: <String, String>{'content-type': 'application/json'},
  );

  test('sends a short, token-authenticated demo conversation', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return completion('Maya: hey, come sit by the fountain');
    });
    final service = AiChatService(client: client);
    addTearDown(service.dispose);

    final thread = sampleThread();
    final reply = await service.reply(
      token: '  hf_test_token  ',
      thread: thread,
      transcript: thread.messages,
    );

    expect(reply, 'hey, come sit by the fountain');
    expect(captured.url.toString(), AiChatService.endpoint);
    expect(captured.headers['Authorization'], 'Bearer hf_test_token');

    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['model'], AiChatService.models.first);
    expect(body['max_tokens'], 60);
    final messages = body['messages'] as List<dynamic>;
    expect((messages.first as Map<String, dynamic>)['role'], 'system');
    expect(
      (messages.first as Map<String, dynamic>)['content'],
      contains('Maya Chen'),
    );
    expect((messages[1] as Map<String, dynamic>)['role'], 'user');
    expect((messages[2] as Map<String, dynamic>)['role'], 'assistant');
  });

  test('falls back to the second model when routing fails', () async {
    final requestedModels = <String>[];
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      requestedModels.add(body['model'] as String);
      if (requestedModels.length == 1) {
        return http.Response('{"error":"model unavailable"}', 404);
      }
      return completion('still here. what’s up?');
    });
    final service = AiChatService(client: client);
    addTearDown(service.dispose);

    final thread = sampleThread();
    final reply = await service.reply(
      token: 'hf_test_token',
      thread: thread,
      transcript: thread.messages,
    );

    expect(reply, 'still here. what’s up?');
    expect(requestedModels, AiChatService.models);
  });

  test('reports a rejected token without retrying another model', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('{"error":"unauthorized"}', 401);
    });
    final service = AiChatService(client: client);
    addTearDown(service.dispose);

    final thread = sampleThread();
    await expectLater(
      service.reply(
        token: 'hf_bad_token',
        thread: thread,
        transcript: thread.messages,
      ),
      throwsA(
        isA<AiChatException>().having(
          (error) => error.message,
          'message',
          contains('rejected that token'),
        ),
      ),
    );
    expect(calls, 1);
  });

  test('rejects an empty token before making a request', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return completion('unused');
    });
    final service = AiChatService(client: client);
    addTearDown(service.dispose);

    await expectLater(
      service.reply(
        token: '   ',
        thread: sampleThread(),
        transcript: <DemoMessage>[],
      ),
      throwsA(isA<AiChatException>()),
    );
    expect(calls, 0);
  });

  test('reports an empty model response', () async {
    final client = MockClient((request) async => completion('   '));
    final service = AiChatService(client: client);
    addTearDown(service.dispose);

    await expectLater(
      service.reply(
        token: 'hf_test_token',
        thread: sampleThread(),
        transcript: <DemoMessage>[],
      ),
      throwsA(
        isA<AiChatException>().having(
          (error) => error.message,
          'message',
          contains('empty reply'),
        ),
      ),
    );
  });
}
