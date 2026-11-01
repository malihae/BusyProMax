import 'package:flutter/material.dart';

/// The strictly monochrome palette used across BusyProMax.
///
/// The app deliberately has no accent color. Interest comes from scale,
/// contrast, thin rules and generous whitespace.
@immutable
class MonoColors extends ThemeExtension<MonoColors> {
  const MonoColors({
    required this.canvas,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.inverse,
    required this.onInverse,
  });

  final Color canvas;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color line;
  final Color inverse;
  final Color onInverse;

  static const light = MonoColors(
    canvas: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F4F4),
    ink: Color(0xFF0A0A0A),
    muted: Color(0xFF6C6C6C),
    line: Color(0xFFE5E5E5),
    inverse: Color(0xFF0A0A0A),
    onInverse: Color(0xFFFFFFFF),
  );

  static const dark = MonoColors(
    canvas: Color(0xFF0A0A0A),
    surface: Color(0xFF161616),
    ink: Color(0xFFF7F7F7),
    muted: Color(0xFFA2A2A2),
    line: Color(0xFF2B2B2B),
    inverse: Color(0xFFF7F7F7),
    onInverse: Color(0xFF0A0A0A),
  );

  @override
  MonoColors copyWith({
    Color? canvas,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? line,
    Color? inverse,
    Color? onInverse,
  }) {
    return MonoColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      inverse: inverse ?? this.inverse,
      onInverse: onInverse ?? this.onInverse,
    );
  }

  @override
  MonoColors lerp(ThemeExtension<MonoColors>? other, double t) {
    if (other is! MonoColors) return this;
    return MonoColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      inverse: Color.lerp(inverse, other.inverse, t)!,
      onInverse: Color.lerp(onInverse, other.onInverse, t)!,
    );
  }
}

extension MonoColorsContext on BuildContext {
  MonoColors get mono =>
      Theme.of(this).extension<MonoColors>() ?? MonoColors.light;
}

class AppTheme {
  const AppTheme._();

  /// Tinos is a Times New Roman-metric-compatible serif, licensed under the
  /// SIL Open Font License and bundled with the app.
  static const serifFamily = 'Tinos';

  static final ThemeData light = _build(Brightness.light, MonoColors.light);
  static final ThemeData dark = _build(Brightness.dark, MonoColors.dark);

  static ThemeData _build(Brightness brightness, MonoColors mono) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final inkText = base.textTheme.apply(
      bodyColor: mono.ink,
      displayColor: mono.ink,
    );
    final serif = inkText.apply(fontFamily: serifFamily);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: brightness,
        ).copyWith(
          primary: mono.ink,
          onPrimary: mono.canvas,
          secondary: mono.ink,
          onSecondary: mono.canvas,
          surface: mono.canvas,
          onSurface: mono.ink,
          onSurfaceVariant: mono.muted,
          outline: mono.line,
          outlineVariant: mono.line,
          surfaceTint: Colors.transparent,
          surfaceContainerLowest: mono.canvas,
          surfaceContainerLow: mono.surface,
          surfaceContainer: mono.surface,
          surfaceContainerHigh: mono.surface,
          surfaceContainerHighest: mono.surface,
          error: mono.ink,
          onError: mono.canvas,
        );

    final labelStyle = inkText.labelLarge?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: mono.canvas,
      canvasColor: mono.canvas,
      extensions: <ThemeExtension<dynamic>>[mono],
      dividerColor: mono.line,
      splashColor: mono.ink.withValues(alpha: 0.055),
      highlightColor: mono.ink.withValues(alpha: 0.035),
      appBarTheme: AppBarTheme(
        backgroundColor: mono.canvas,
        foregroundColor: mono.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: 60,
      ),
      textTheme: inkText.copyWith(
        displayLarge: serif.displayLarge?.copyWith(
          fontSize: 60,
          height: 0.96,
          letterSpacing: -1.8,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: serif.displayMedium?.copyWith(
          fontSize: 48,
          height: 0.98,
          letterSpacing: -1.2,
        ),
        displaySmall: serif.displaySmall?.copyWith(
          fontSize: 40,
          height: 1,
          letterSpacing: -0.8,
        ),
        headlineLarge: serif.headlineLarge?.copyWith(
          fontSize: 36,
          height: 1.02,
          letterSpacing: -0.7,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: serif.headlineMedium?.copyWith(
          fontSize: 30,
          height: 1.06,
          letterSpacing: -0.4,
        ),
        headlineSmall: serif.headlineSmall?.copyWith(
          fontSize: 24,
          height: 1.1,
          letterSpacing: -0.2,
        ),
        titleLarge: serif.titleLarge?.copyWith(
          fontSize: 22,
          height: 1.08,
          letterSpacing: -0.2,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: inkText.titleMedium?.copyWith(
          fontSize: 16,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: inkText.bodyLarge?.copyWith(
          fontSize: 15.5,
          height: 1.55,
          letterSpacing: -0.1,
        ),
        bodyMedium: inkText.bodyMedium?.copyWith(fontSize: 13.5, height: 1.5),
        bodySmall: inkText.bodySmall?.copyWith(
          fontSize: 12,
          height: 1.4,
          color: mono.muted,
        ),
        labelLarge: labelStyle,
        labelMedium: inkText.labelMedium?.copyWith(
          fontSize: 10.5,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: mono.ink,
          foregroundColor: mono.canvas,
          disabledBackgroundColor: mono.line,
          disabledForegroundColor: mono.muted,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: mono.ink,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: BorderSide(color: mono.line, width: 0.9),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mono.ink,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(0, 40),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      iconTheme: IconThemeData(color: mono.ink, size: 22),
      dividerTheme: DividerThemeData(
        color: mono.line,
        thickness: 0.8,
        space: 0.8,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: mono.ink,
        selectionColor: mono.ink.withValues(alpha: 0.16),
        selectionHandleColor: mono.ink,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: mono.ink,
        linearTrackColor: mono.line,
        circularTrackColor: mono.line,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: mono.inverse,
        contentTextStyle: TextStyle(
          color: mono.onInverse,
          fontSize: 13,
          height: 1.4,
        ),
        actionTextColor: mono.onInverse,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: mono.canvas,
        modalBackgroundColor: mono.canvas,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black.withValues(alpha: 0.45),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: TextStyle(color: mono.onInverse, fontSize: 12),
        decoration: BoxDecoration(
          color: mono.inverse,
          borderRadius: BorderRadius.circular(8),
        ),
        waitDuration: const Duration(milliseconds: 450),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: mono.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: mono.line, width: 0.8),
        ),
        titleTextStyle: serif.headlineSmall?.copyWith(
          fontSize: 25,
          color: mono.ink,
        ),
        contentTextStyle: inkText.bodyMedium?.copyWith(
          color: mono.muted,
          height: 1.5,
        ),
      ),
    );
  }
}
