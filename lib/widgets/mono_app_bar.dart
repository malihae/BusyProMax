import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MonoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MonoAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.toolbarHeight = 60,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: toolbarHeight,
      backgroundColor: mono.canvas,
      foregroundColor: mono.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: leading == null ? 0 : 58,
      leading: leading,
      titleSpacing: leading == null ? 22 : 0,
      title: DefaultTextStyle.merge(
        style: TextStyle(color: mono.ink),
        child: title,
      ),
      actions: [...actions, const SizedBox(width: 10)],
      shape: Border(bottom: BorderSide(color: mono.line, width: 0.8)),
    );
  }
}

class MonoBarButton extends StatelessWidget {
  const MonoBarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 20,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: size, color: mono.ink),
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        minimumSize: const Size(44, 44),
      ),
    );
  }
}

class AppTitle extends StatelessWidget {
  const AppTitle({super.key, required this.title, this.subtitle, this.leading});

  final String title;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mono.muted,
                    fontSize: 10.5,
                    letterSpacing: 0.2,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class BrandedTitle extends StatelessWidget {
  const BrandedTitle({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: SizedBox.shrink()),
        Text(
          'BUSYPROMAX',
          style: TextStyle(
            fontFamily: AppTheme.serifFamily,
            color: context.mono.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: trailing ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
