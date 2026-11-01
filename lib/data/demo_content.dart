import '../models/demo_thread.dart';

/// All sample conversations are fictional and live only in memory.
/// They exist so the messaging activity feels complete without scraping,
/// impersonating a real account, or sending anything.
List<DemoThread> seedDemoThreads() {
  final now = DateTime.now();

  DateTime ago(Duration duration) => now.subtract(duration);

  return <DemoThread>[
    DemoThread(
      id: 'direct-maya',
      name: 'Maya Chen',
      initials: 'MC',
      channel: DemoChannel.direct,
      note: 'Sample conversation',
      messages: [
        DemoMessage(
          text: 'are you still walking down by the quad?',
          isMine: false,
          sentAt: ago(const Duration(minutes: 43)),
        ),
        DemoMessage(
          text: 'yeah, heading toward the library',
          isMine: true,
          sentAt: ago(const Duration(minutes: 39)),
        ),
        DemoMessage(
          text: 'okay! save me a seat if you get there first',
          isMine: false,
          sentAt: ago(const Duration(minutes: 11)),
        ),
      ],
    ),
    DemoThread(
      id: 'direct-noah',
      name: 'Noah Park',
      initials: 'NP',
      channel: DemoChannel.direct,
      messages: [
        DemoMessage(
          text: 'that playlist you sent is actually perfect',
          isMine: true,
          sentAt: ago(const Duration(hours: 3, minutes: 10)),
        ),
        DemoMessage(
          text: 'told you. track four is the one',
          isMine: false,
          sentAt: ago(const Duration(hours: 2, minutes: 48)),
        ),
      ],
    ),
    DemoThread(
      id: 'direct-studio',
      name: 'The Studio',
      initials: 'TS',
      channel: DemoChannel.direct,
      note: 'Sample studio',
      messages: [
        DemoMessage(
          text: 'your prints are ready whenever you want to swing by',
          isMine: false,
          sentAt: ago(const Duration(days: 1, hours: 2)),
        ),
      ],
    ),
    DemoThread(
      id: 'direct-alex',
      name: 'Alex Rivera',
      initials: 'AR',
      channel: DemoChannel.direct,
      messages: [
        DemoMessage(
          text: 'coffee before the 2pm?',
          isMine: false,
          sentAt: ago(const Duration(minutes: 24)),
        ),
        DemoMessage(
          text: 'I can be there in ten',
          isMine: true,
          sentAt: ago(const Duration(minutes: 20)),
        ),
      ],
    ),
    DemoThread(
      id: 'sms-mom',
      name: 'Mom',
      initials: 'M',
      channel: DemoChannel.sms,
      messages: [
        DemoMessage(
          text: 'did you eat something before class?',
          isMine: false,
          sentAt: ago(const Duration(hours: 1, minutes: 5)),
        ),
        DemoMessage(
          text: 'yes, grabbed a bagel on the way',
          isMine: true,
          sentAt: ago(const Duration(hours: 1)),
        ),
        DemoMessage(
          text: 'good. text me when you get home',
          isMine: false,
          sentAt: ago(const Duration(minutes: 42)),
        ),
      ],
    ),
    DemoThread(
      id: 'sms-jordan',
      name: 'Jordan',
      initials: 'J',
      channel: DemoChannel.sms,
      messages: [
        DemoMessage(
          text: "I'm outside the east entrance",
          isMine: false,
          sentAt: ago(const Duration(minutes: 18)),
        ),
        DemoMessage(
          text: 'two minutes, the elevator is slow',
          isMine: true,
          sentAt: ago(const Duration(minutes: 16)),
        ),
      ],
    ),
    DemoThread(
      id: 'sms-priya',
      name: 'Priya',
      initials: 'P',
      channel: DemoChannel.sms,
      messages: [
        DemoMessage(
          text: 'the reading for tomorrow is so long',
          isMine: false,
          sentAt: ago(const Duration(hours: 4)),
        ),
        DemoMessage(
          text: 'meet at the cafe and we can split it?',
          isMine: true,
          sentAt: ago(const Duration(hours: 3, minutes: 50)),
        ),
      ],
    ),
    DemoThread(
      id: 'sms-ride',
      name: 'Campus Ride',
      initials: 'CR',
      channel: DemoChannel.sms,
      note: 'Sample notification',
      messages: [
        DemoMessage(
          text: 'Your sample ride is 4 minutes away.',
          isMine: false,
          sentAt: ago(const Duration(minutes: 8)),
        ),
      ],
    ),
  ];
}
