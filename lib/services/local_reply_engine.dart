import '../models/demo_thread.dart';

/// Short, deterministic replies used when no Hugging Face token is connected.
///
/// These are sample lines, not an AI model. The chat UI labels them
/// "LOCAL SAMPLE" so they cannot be mistaken for a generated or delivered
/// message.
class LocalReplyEngine {
  const LocalReplyEngine._();

  static const _replies = <String, List<String>>{
    'direct-maya': [
      'yeah, same here. the quad is quiet today',
      'i’m by the library steps. come sit?',
      'okay but only if we get coffee after',
    ],
    'direct-noah': [
      'fair. track four still wins though',
      'i’ll send you another one later',
      'honestly? valid',
    ],
    'direct-studio': [
      'the prints are on the front desk',
      'come by before six if you can',
      'no rush. they’ll be safe here',
    ],
    'direct-alex': [
      'ten works. usual place?',
      'i’m already here, no rush',
      'cool. see you in a bit',
    ],
    'sms-mom': [
      'okay sweetheart. drink some water',
      'text me when you’re home',
      'did you take your keys?',
    ],
    'sms-jordan': [
      'fine, i’ll wait by the door',
      'two minutes is two minutes',
      'you always say that',
    ],
    'sms-priya': [
      'the reading is endless',
      'cafe at four?',
      'bring your notes and i’ll bring mine',
    ],
  };

  static const _defaultReplies = <String>[
    'yeah, i get that',
    'same. what are you up to?',
    'okay, tell me more',
  ];

  static String replyFor(DemoThread thread, String input) {
    final lower = input.toLowerCase();
    if (lower.contains('?')) {
      return _pick(thread.id, <String>[
        'yeah, maybe. what are you thinking?',
        'honestly, no idea. you?',
        'probably. ask me again in five',
      ]);
    }
    if (lower.contains('hey') ||
        lower.contains('hi') ||
        lower.contains('hello')) {
      return _pick(thread.id, <String>[
        'hey. you around?',
        'hey! what’s up?',
        'hi — walk with me?',
      ]);
    }
    if (lower.contains('lol') ||
        lower.contains('haha') ||
        lower.contains('😂')) {
      return _pick(thread.id, <String>[
        'right? that’s exactly it',
        'i knew you’d laugh',
      ]);
    }
    return _pick(thread.id, _replies[thread.id] ?? _defaultReplies);
  }

  static String _pick(String id, List<String> choices) {
    final index = (id.hashCode + choices.length) % choices.length;
    return choices[index.abs() % choices.length];
  }
}
