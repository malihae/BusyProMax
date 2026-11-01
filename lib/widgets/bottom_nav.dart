import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.keyName,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String keyName;
}

const navDestinations = <NavDestination>[
  NavDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    keyName: 'home',
  ),
  NavDestination(
    label: 'Activities',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
    keyName: 'activities',
  ),
  NavDestination(
    label: 'Favorites',
    icon: Icons.star_outline_rounded,
    selectedIcon: Icons.star_rounded,
    keyName: 'favorites',
  ),
  NavDestination(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    keyName: 'settings',
  ),
];

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Container(
      decoration: BoxDecoration(
        color: mono.canvas,
        border: Border(top: BorderSide(color: mono.line, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  for (var index = 0; index < navDestinations.length; index++)
                    Expanded(
                      child: _NavItem(
                        destination: navDestinations[index],
                        selected: currentIndex == index,
                        onTap: () {
                          if (currentIndex == index) return;
                          HapticFeedback.selectionClick();
                          onSelected(index);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('nav-${destination.keyName}'),
          onTap: onTap,
          splashColor: mono.ink.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: selected ? 22 : 0,
                height: 1.8,
                color: mono.ink,
              ),
              const SizedBox(height: 9),
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 21,
                color: selected ? mono.ink : mono.muted,
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? mono.ink : mono.muted,
                  fontSize: 9.5,
                  height: 1,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
