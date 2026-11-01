import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ContentFrame extends StatelessWidget {
  const ContentFrame({
    super.key,
    required this.child,
    this.maxWidth = 840,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: color ?? context.mono.muted),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    this.trailing,
    this.showRule = true,
  });

  final String label;
  final Widget? trailing;
  final bool showRule;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: mono.muted),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
        if (showRule) ...[
          const SizedBox(height: 8),
          Container(height: 0.8, color: mono.line),
        ],
      ],
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.eyebrow = '',
    required this.title,
    this.description,
    this.trailing,
    this.bottom = 26,
  });

  final String eyebrow;
  final String title;
  final String? description;
  final Widget? trailing;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final mono = context.mono;

    return Padding(
      padding: EdgeInsets.only(top: 28, bottom: bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow.isNotEmpty) ...[
            Row(
              children: [
                Expanded(child: Eyebrow(eyebrow)),
                ?trailing,
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text(title, style: text.headlineLarge?.copyWith(fontSize: 40)),
          if (description != null) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                description!,
                style: text.bodyMedium?.copyWith(
                  color: mono.muted,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.showMonogram = true,
    this.color,
    this.monogramColor,
    this.fontSize = 10.5,
  });

  final bool showMonogram;
  final Color? color;
  final Color? monogramColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final foreground = color ?? mono.ink;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMonogram) ...[
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'B',
              style: TextStyle(
                fontFamily: AppTheme.serifFamily,
                fontSize: 15,
                height: 1,
                color: monogramColor ?? mono.canvas,
              ),
            ),
          ),
          const SizedBox(width: 9),
        ],
        Text(
          'BUSYPROMAX',
          style: TextStyle(
            fontFamily: AppTheme.serifFamily,
            color: foreground,
            fontSize: fontSize + 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class DemoPill extends StatelessWidget {
  const DemoPill({super.key, this.inverted = false, this.label = 'DEMO'});

  final bool inverted;
  final String label;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final foreground = inverted ? mono.onInverse : mono.ink;
    final background = inverted ? mono.inverse : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: inverted ? Colors.transparent : mono.line,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          height: 1,
        ),
      ),
    );
  }
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
    this.margin = EdgeInsets.zero,
    this.compact = false,
  });

  final String text;
  final IconData icon;
  final EdgeInsetsGeometry margin;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Container(
      margin: margin,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 10 : 13,
      ),
      decoration: BoxDecoration(
        color: mono.surface,
        border: Border.all(color: mono.line, width: 0.8),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: mono.muted),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: compact ? 10.5 : 11.5,
                height: 1.45,
                color: mono.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonoAvatar extends StatelessWidget {
  const MonoAvatar({
    super.key,
    required this.initials,
    this.size = 52,
    this.inverted = false,
  });

  final String initials;
  final double size;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: inverted ? mono.inverse : mono.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: inverted ? mono.inverse : mono.line,
          width: 0.9,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppTheme.serifFamily,
          fontSize: size * 0.32,
          height: 1,
          fontWeight: FontWeight.w700,
          color: inverted ? mono.onInverse : mono.ink,
        ),
      ),
    );
  }
}

class ThinRule extends StatelessWidget {
  const ThinRule({super.key, this.vertical = 20});

  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Container(height: 0.8, color: context.mono.line),
    );
  }
}

class LoadingDot extends StatefulWidget {
  const LoadingDot({super.key, this.color});

  final Color? color;

  @override
  State<LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<LoadingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.25,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color ?? context.mono.muted,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
