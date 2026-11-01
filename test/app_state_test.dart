import 'package:busypro_max/models/demo_thread.dart';
import 'package:busypro_max/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('favorites and theme persist locally', () async {
    final state = await AppState.load();
    expect(state.favoriteCount, 0);

    await state.toggleFavorite('food');
    await state.toggleFavorite('messages');
    await state.setThemeMode(ThemeMode.dark);

    expect(state.isFavorite('food'), isTrue);
    expect(state.isFavorite('messages'), isTrue);
    expect(state.favoriteActivities.length, 2);
    expect(state.themeMode, ThemeMode.dark);

    final reloaded = await AppState.load();
    expect(reloaded.isFavorite('food'), isTrue);
    expect(reloaded.isFavorite('messages'), isTrue);
    expect(reloaded.themeMode, ThemeMode.dark);
  });

  test('demo messages stay local and reset restores seed data', () async {
    final state = await AppState.load();
    final directThreads = state.threadsFor(DemoChannel.direct);
    final before = directThreads.first.messages.length;
    await state.toggleFavorite('video-call');
    expect(state.isFavorite('video-call'), isTrue);

    state.sendMessage(directThreads.first.id, 'A local reply');
    expect(directThreads.first.messages.length, before + 1);
    expect(directThreads.first.messages.last.text, 'A local reply');
    expect(directThreads.first.messages.last.isMine, isTrue);

    await state.resetDemoData();
    expect(state.favoriteCount, 0);
    expect(state.threadsFor(DemoChannel.direct).first.messages.length, before);
    expect(state.threadsFor(DemoChannel.sms), isNotEmpty);
  });

  test('malformed stored theme falls back to system', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'busypro.themeMode': 'sepia',
      'busypro.favorites': <String>['villa'],
    });
    final state = await AppState.load();
    expect(state.themeMode, ThemeMode.system);
    expect(state.favoriteActivities.single.id, 'villa');
  });
}
