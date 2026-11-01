import 'package:flutter/material.dart';

class MonoPageRoute<T> extends PageRouteBuilder<T> {
  MonoPageRoute({required Widget page, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
            return child;
          }
          final curved = animation.drive(
            CurveTween(curve: Curves.easeOutCubic),
          );
          final position = Tween<Offset>(
            begin: const Offset(0, 0.028),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(position: position, child: child),
          );
        },
      );
}
