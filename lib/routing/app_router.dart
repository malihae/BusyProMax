import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../screens/messages_screen.dart';
import '../screens/root_shell.dart';
import '../screens/texting_screen.dart';
import '../screens/video_call_screen.dart';
import '../screens/villa_security_screen.dart';
import '../screens/web_activity_screen.dart';
import 'mono_page_route.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const videoCall = '/video-call';
  static const messages = '/messages';
  static const texting = '/texting';
  static const food = '/food';
  static const shopping = '/shop';
  static const villa = '/villa';
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.videoCall => const VideoCallScreen(),
      AppRoutes.messages => const MessagesScreen(),
      AppRoutes.texting => const TextingScreen(),
      AppRoutes.food => WebActivityScreen(activity: activityById('food')),
      AppRoutes.shopping => WebActivityScreen(
        activity: activityById('shopping'),
      ),
      AppRoutes.villa => const VillaSecurityScreen(),
      _ => const RootShell(),
    };

    return MonoPageRoute<dynamic>(settings: settings, page: page);
  }
}
