import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/demo_thread.dart';

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Calls Hugging Face Inference Providers through its OpenAI-compatible
/// chat-completions endpoint.
///
/// The user's personal token is sent only in the Authorization header, never
/// in the request body or to any other host. The service is deliberately small
/// so the demo has no backend and no server-side secret.
class AiChatService {
  AiChatService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static const endpoint = 'https://router.huggingface.co/v1/chat/completions';
  static const tokenUrl = 'https://huggingface.co/settings/tokens';

  /// Tried in order. The second model has a wider set of live providers, so a
  /// routing gap on the first does not break the conversation.
  static const models = <String>[
    'Qwen/Qwen3-4B-Instruct-2507',
    'Qwen/Qwen2.5-7B-Instruct',
  ];

  final http.Client _client;
  final bool _ownsClient;

  Future<String> reply({
    required String token,
    required DemoThread thread,
    required List<DemoMessage> transcript,
  }) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      throw const AiChatException(
        'Add a Hugging Face token in Settings to turn on AI replies.',
      );
    }

    final recent = transcript.length > 10
        ? transcript.sublist(transcript.length - 10)
        : transcript;

    AiChatException? lastModelError;
    for (final model in models) {
      try {
        return await _request(
          token: trimmedToken,
          thread: thread,
          recent: recent,
          model: model,
        );
      } on _ModelUnavailable catch (error) {
        lastModelError = AiChatException(
          'The AI model is unavailable right now (${error.statusCode}).',
        );
      }
    }

    throw lastModelError ??
        const AiChatException('The AI could not reply. Try again in a moment.');
  }

  Future<String> _request({
    required String token,
    required DemoThread thread,
    required List<DemoMessage> recent,
    required String model,
  }) async {
    final payload = <String, dynamic>{
      'model': model,
      'messages': <Map<String, String>>[
        <String, String>{'role': 'system', 'content': _systemPrompt(thread)},
        for (final message in recent)
          <String, String>{
            'role': message.isMine ? 'user' : 'assistant',
            'content': message.text,
          },
      ],
      'max_tokens': 60,
      'temperature': 0.85,
      'top_p': 0.9,
      'stream': false,
    };

    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(endpoint),
            headers: <String, String>{
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const AiChatException(
        'The AI took too long to reply. Check your connection and try again.',
      );
    } on SocketException {
      throw const AiChatException(
        'No connection to Hugging Face. Try again when you are online.',
      );
    } on http.ClientException {
      throw const AiChatException(
        'The AI connection dropped. Try sending again.',
      );
    } catch (_) {
      throw const AiChatException(
        'The AI could not reply. Try again in a moment.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AiChatException(
        'Hugging Face rejected that token. Add a valid Inference Providers token in Settings.',
      );
    }
    if (response.statusCode == 402) {
      throw const AiChatException(
        'Hugging Face needs credits for this model. Check your account and try again.',
      );
    }
    if (response.statusCode == 429) {
      throw const AiChatException(
        'The AI is busy right now. Wait a moment and try again.',
      );
    }
    if (response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 422 ||
        response.statusCode == 503) {
      throw _ModelUnavailable(response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiChatException(
        'Hugging Face could not reply (${response.statusCode}). Try again.',
      );
    }

    return _parse(response);
  }

  String _parse(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response shape.');
      }
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        throw const FormatException('No choices returned.');
      }
      final first = choices.first;
      if (first is! Map<String, dynamic>) {
        throw const FormatException('Unexpected choice.');
      }
      final message = first['message'];
      if (message is! Map<String, dynamic>) {
        throw const FormatException('No message returned.');
      }
      final content = message['content'];
      if (content is! String) {
        throw const FormatException('No text returned.');
      }
      final clean = _clean(content);
      if (clean.isEmpty) {
        throw const FormatException('Empty text.');
      }
      return clean;
    } on FormatException {
      throw const AiChatException(
        'Hugging Face returned an empty reply. Try sending again.',
      );
    } catch (_) {
      throw const AiChatException(
        'The AI reply could not be read. Try sending again.',
      );
    }
  }

  static String _systemPrompt(DemoThread thread) {
    final persona = _personas[thread.id] ?? _defaultPersona;
    return 'You are a fictional contact named ${thread.name} inside BusyProMax, '
        'a private demo messaging app. $persona '
        'Write one short, natural text message. Keep it under 18 words, casual, '
        'no emojis, no hashtags, no markdown, and never prefix it with your name. '
        'Never claim to be a real person or that a message was delivered. '
        'If asked whether you are AI, say you are an AI demo reply.';
  }

  static String _clean(String raw) {
    var text = raw.trim();
    text = text.replaceFirst(RegExp(r'^[A-Za-z][A-Za-z .]{0,22}:\s*'), '');
    text = text.replaceAll(RegExp(r'[*_`#]'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    if (text.length > 320) {
      text = '${text.substring(0, 317).trimRight()}…';
    }
    return text.trim();
  }

  static const _defaultPersona =
      'You are warm, brief, and a little dry, like a friend texting between classes.';

  static const _personas = <String, String>{
    'direct-maya': 'Maya is a warm, quietly funny friend who keeps replies short and asks small follow-up questions.',
    'direct-noah': 'Noah is dry, relaxed, and teasing in a friendly way. He rarely uses more than one sentence.',
    'direct-studio': 'The Studio is a small print shop. Its replies are calm, practical, and friendly.',
    'direct-alex': 'Alex is an easygoing friend making plans. He is casual, direct, and never over-explains.',
    'sms-mom': 'Mom is caring and practical. She checks in without being dramatic and keeps it brief.',
    'sms-jordan':
        'Jordan is blunt, funny, and impatient in an affectionate way.',
    'sms-priya': 'Priya is a studious friend who is warm, a little tired, and always up for coffee.',
    'sms-ride': 'Campus Ride is an automated sample notification. Reply in one short, neutral line.',
  };

  void dispose() {
    if (_ownsClient) _client.close();
  }
}

class _ModelUnavailable implements Exception {
  const _ModelUnavailable(this.statusCode);

  final int statusCode;
}
