import 'package:flutter/material.dart';

import '../models/demo_thread.dart';
import 'conversation_list_screen.dart';

class TextingScreen extends StatelessWidget {
  const TextingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConversationListScreen(
      channel: DemoChannel.sms,
      title: 'Texting',
      notice: 'Demo chats. No SMS is sent.',
      emptyLabel: 'No matches.',
    );
  }
}
