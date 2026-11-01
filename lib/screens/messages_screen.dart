import 'package:flutter/material.dart';

import '../models/demo_thread.dart';
import 'conversation_list_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConversationListScreen(
      channel: DemoChannel.direct,
      title: 'Messages',
      notice: 'Demo chats. Nothing is sent to Instagram.',
      emptyLabel: 'No matches.',
    );
  }
}
