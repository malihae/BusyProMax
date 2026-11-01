import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/activity.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.activity,
    this.keyPrefix = 'favorite',
    this.color,
  });

  final ActivityDefinition activity;
  final String keyPrefix;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final isFavorite = context.select<AppState, bool>(
      (state) => state.isFavorite(activity.id),
    );

    return Tooltip(
      message: isFavorite
          ? 'Remove from favorites'
          : 'Add ${activity.title} to favorites',
      child: Semantics(
        button: true,
        toggled: isFavorite,
        label: isFavorite
            ? 'Remove ${activity.title} from favorites'
            : 'Add ${activity.title} to favorites',
        child: InkResponse(
          key: Key('$keyPrefix-${activity.id}'),
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<AppState>().toggleFavorite(activity.id);
          },
          radius: 21,
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  key: ValueKey<bool>(isFavorite),
                  size: 21,
                  color: color ?? mono.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity, required this.number});

  final ActivityDefinition activity;
  final int number;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;
    final label = number.toString().padLeft(2, '0');

    return Semantics(
      button: true,
      label: 'Open ${activity.title}',
      child: Material(
        color: mono.inverse,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              activity.image,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: mono.inverse,
                child: Center(
                  child: Icon(activity.icon, size: 25, color: mono.onInverse),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x1A000000), Color(0xD9000000)],
                  stops: <double>[0.38, 1],
                ),
              ),
            ),
            InkWell(
              key: Key('open-${activity.id}'),
              onTap: () => Navigator.of(context).pushNamed(activity.route),
              splashColor: Colors.white.withValues(alpha: 0.08),
              highlightColor: Colors.white.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: AppTheme.serifFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.92),
                          letterSpacing: 0.7,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      activity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge?.copyWith(
                        fontFamily: AppTheme.serifFamily,
                        fontSize: 20,
                        height: 1.05,
                        color: Colors.white,
                        shadows: const <Shadow>[
                          Shadow(color: Color(0x66000000), blurRadius: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.36),
                  shape: BoxShape.circle,
                ),
                child: FavoriteButton(
                  activity: activity,
                  keyPrefix: 'favorite',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.activity,
    this.keyPrefix = 'row',
  });

  final ActivityDefinition activity;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: 'Open ${activity.title}',
      child: Material(
        color: mono.canvas,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            InkWell(
              key: Key('$keyPrefix-${activity.id}'),
              onTap: () => Navigator.of(context).pushNamed(activity.route),
              splashColor: mono.ink.withValues(alpha: 0.05),
              highlightColor: mono.ink.withValues(alpha: 0.03),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
                decoration: BoxDecoration(
                  border: Border.all(color: mono.line, width: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        activity.image,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 54,
                          height: 54,
                          color: mono.surface,
                          alignment: Alignment.center,
                          child: Icon(activity.icon, size: 20, color: mono.ink),
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 32),
                            child: Text(
                              activity.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleLarge?.copyWith(
                                fontSize: 21,
                                height: 1.05,
                              ),
                            ),
                          ),
                          if (activity.opensWebsite) ...[
                            const SizedBox(height: 5),
                            Text(
                              activity.domain,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                fontSize: 9.5,
                                letterSpacing: 0.1,
                                color: mono.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      activity.opensWebsite
                          ? Icons.north_east_rounded
                          : Icons.arrow_forward_rounded,
                      size: 15,
                      color: mono.muted,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 3,
              right: 4,
              child: FavoriteButton(
                activity: activity,
                keyPrefix: 'favorite-$keyPrefix',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
