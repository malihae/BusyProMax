import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/common.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppState>().favoriteActivities;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('favorites-scroll'),
        padding: const EdgeInsets.only(bottom: 32),
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Favorites'),
              if (favorites.isEmpty)
                _EmptyFavorites(onExplore: onExplore)
              else ...[
                const SectionLabel(label: 'Saved'),
                const SizedBox(height: 12),
                for (var index = 0; index < favorites.length; index++) ...[
                  ActivityRow(
                    activity: favorites[index],
                    keyPrefix: 'favorite-row',
                  ),
                  if (index != favorites.length - 1) const SizedBox(height: 10),
                ],
                const SizedBox(height: 20),
                const DemoNotice(
                  icon: Icons.lock_outline_rounded,
                  text: 'Saved on this phone.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 40, 26, 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mono.line, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: mono.line, width: 0.8),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.star_outline_rounded, size: 34, color: mono.ink),
          ),
          const SizedBox(height: 24),
          Text(
            'Nothing pinned yet.',
            textAlign: TextAlign.center,
            style: text.headlineSmall?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              'Star an activity to keep it here.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: mono.muted, height: 1.55),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('explore-from-favorites'),
            onPressed: onExplore,
            child: const Text('Browse activities'),
          ),
        ],
      ),
    );
  }
}
