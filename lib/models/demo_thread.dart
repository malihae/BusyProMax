enum DemoChannel { direct, sms }

/// Where an incoming line came from. Sample lines are part of the fictional
/// transcript; local lines are the offline fallback; AI lines were generated
/// by Hugging Face. The UI labels the latter two explicitly.
enum DemoMessageSource { sample, local, ai }

class DemoMessage {
  const DemoMessage({
    required this.text,
    required this.isMine,
    required this.sentAt,
    this.source = DemoMessageSource.sample,
  });

  final String text;
  final bool isMine;
  final DateTime sentAt;
  final DemoMessageSource source;
}

class DemoThread {
  DemoThread({
    required this.id,
    required this.name,
    required this.initials,
    required this.channel,
    this.note = 'Demo contact',
    List<DemoMessage>? messages,
  }) : messages = messages ?? <DemoMessage>[];

  final String id;
  final String name;
  final String initials;
  final DemoChannel channel;
  final String note;
  final List<DemoMessage> messages;

  DemoMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  String get preview {
    final message = lastMessage;
    if (message == null) return 'No messages yet';
    return message.isMine ? 'You: ${message.text}' : message.text;
  }
}
