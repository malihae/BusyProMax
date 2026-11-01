import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import 'activities_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _selectTab(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSeeAll: () => _selectTab(1)),
          const ActivitiesScreen(),
          FavoritesScreen(onExplore: () => _selectTab(1)),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onSelected: _selectTab,
      ),
    );
  }
}
