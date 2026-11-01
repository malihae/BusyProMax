import 'package:busypro_max/app.dart';
import 'package:busypro_max/models/demo_thread.dart';
import 'package:busypro_max/screens/home_screen.dart';
import 'package:busypro_max/screens/messages_screen.dart';
import 'package:busypro_max/screens/settings_screen.dart';
import 'package:busypro_max/screens/video_call_screen.dart';
import 'package:busypro_max/screens/villa_security_screen.dart';
import 'package:busypro_max/state/app_state.dart';
import 'package:busypro_max/widgets/activity_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> pumpApp(
    WidgetTester tester, {
    Size size = const Size(1170, 2532),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final state = await AppState.load();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const BusyProMaxApp(),
      ),
    );
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('home renders the moodboard, six activities and tabs', (
    tester,
  ) async {
    await pumpApp(tester);

    // The landing screen has a page header, but no tagline or demo badge.
    expect(find.text('BusyProMax'), findsOneWidget);
    expect(find.text('Your time. Your space. Your vibe.'), findsNothing);
    expect(find.text('LOOK BUSY'), findsOneWidget);
    expect(find.text('DEMO'), findsNothing);
    expect(find.byType(ActivityCard), findsNWidgets(6));
    expect(find.byKey(const Key('open-video-call')), findsOneWidget);
    expect(find.byKey(const Key('open-messages')), findsOneWidget);
    expect(find.byKey(const Key('open-food')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-activities')));
    await tester.pumpAndSettle();
    expect(find.text('Activities'), findsWidgets);
    expect(find.byKey(const Key('row-villa')), findsOneWidget);
  });

  testWidgets('star saves an activity without opening it', (tester) async {
    final state = await pumpApp(tester);

    await tester.ensureVisible(find.byKey(const Key('favorite-video-call')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('favorite-video-call')));
    await tester.pumpAndSettle();

    expect(state.isFavorite('video-call'), isTrue);
    expect(find.byType(VideoCallScreen), findsNothing);

    await tester.tap(find.byKey(const Key('nav-favorites')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('favorite-row-video-call')), findsOneWidget);
  });

  testWidgets('theme choice persists through app state', (tester) async {
    final state = await pumpApp(tester);

    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-dark')));
    await tester.pumpAndSettle();

    expect(state.themeMode, ThemeMode.dark);
    final settingsContext = tester.element(find.byType(SettingsScreen));
    expect(Theme.of(settingsContext).brightness, Brightness.dark);
  });

  testWidgets('demo message is added locally and never sent', (tester) async {
    final state = await pumpApp(tester);

    await tester.tap(find.byKey(const Key('nav-activities')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('row-messages')));
    await tester.tap(find.byKey(const Key('row-messages')));
    await tester.pumpAndSettle();
    expect(find.byType(MessagesScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('thread-direct-maya')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('chat-input')),
      'Meet at the library?',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    final thread = state.threadById('direct-maya');
    expect(thread, isNotNull);
    expect(
      thread!.messages.any(
        (message) => message.isMine && message.text == 'Meet at the library?',
      ),
      isTrue,
    );
    expect(find.text('Meet at the library?'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('ai-status')),
        matching: find.text('LOCAL SAMPLE'),
      ),
      findsOneWidget,
    );

    // With no token the offline sample engine replies, clearly labelled.
    await tester.pump(const Duration(seconds: 1));
    expect(thread.messages.length, 5);
    expect(thread.messages.last.isMine, isFalse);
    expect(thread.messages.last.source, DemoMessageSource.local);
    expect(find.textContaining('LOCAL SAMPLE'), findsWidgets);
  });

  testWidgets('reset clears favorites and restores sample threads', (
    tester,
  ) async {
    final state = await pumpApp(tester);
    await state.toggleFavorite('food');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('reset-demo-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reset-demo-data')));
    await tester.pumpAndSettle();

    expect(find.text('Reset demo data?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-reset')));
    await tester.pumpAndSettle();

    expect(state.favoriteCount, 0);
    expect(state.threadById('direct-maya'), isNotNull);
  });

  testWidgets('camera failure keeps the simulated call usable', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('open-video-call')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('No one is connected'), findsOneWidget);
    expect(find.byKey(const Key('call-end')), findsOneWidget);
    expect(find.textContaining('SIMULATION'), findsWidgets);

    // Widget tests have no camera implementation. The preview may be absent,
    // but the labeled simulated call surface must remain usable.
    final continueButton = find.byKey(const Key('continue-without-preview'));
    if (continueButton.evaluate().isNotEmpty) {
      await tester.tap(continueButton);
      await tester.pump();
      expect(find.text('Preview off'), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('call-end')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('villa opens the bundled AI loop, not a website', (tester) async {
    await pumpApp(tester);

    await tester.ensureVisible(find.byKey(const Key('open-villa')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-villa')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(VillaSecurityScreen), findsOneWidget);
    expect(find.text('VILLA 09'), findsOneWidget);
    expect(find.text('ESTATE CAM'), findsOneWidget);
    expect(find.text('AI DEMO'), findsOneWidget);
    expect(find.text('PRE-GENERATED  ·  NOT LIVE'), findsOneWidget);
    expect(find.byKey(const Key('villa-back-home')), findsOneWidget);

    // Widget tests have no video plugin. The poster and controls must remain.
    expect(find.byKey(const Key('villa-play-pause')), findsOneWidget);

    await tester.tap(find.byKey(const Key('villa-back-home')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('main tabs hold together on a narrow 320px phone', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(960, 1920));

    expect(find.byKey(const Key('open-video-call')), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-activities')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('row-villa')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-favorites')));
    await tester.pumpAndSettle();
    expect(find.text('Nothing pinned yet.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reset-demo-data')), findsOneWidget);
  });

  testWidgets('external browser failure degrades to a safe fallback', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('nav-activities')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('row-food')));
    await tester.tap(find.byKey(const Key('row-food')));
    await tester.pumpAndSettle();

    // Unit tests have no WebView platform implementation, so the screen must
    // present its external-browser fallback instead of crashing.
    expect(find.text('Open this site in your browser'), findsOneWidget);
    expect(find.byKey(const Key('fallback-open-browser')), findsOneWidget);
  });
}
