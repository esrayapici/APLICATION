import 'package:material_ui/material_ui.dart';

/// Uygulama renkleri: "Neon Gece" paleti.
/// Renk değişikliği için yalnızca bu dosyayı düzenlemek yeterli.
class AppColors {
  const AppColors._();

  static const background = Color(0xFF0B0716); // gece moru
  static const card = Color(0xFF1A1230);
  static const cardHigh = Color(0xFF221838);
  static const line = Color(0xFF35285A);
  static const lineStrong = Color(0xFF463670);
  static const primary = Color(0xFFB45CFF); // neon mor
  static const primaryLight = Color(0xFFD3A1FF);
  static const primaryContainer = Color(0xFF2C1A4A);
  static const onPrimary = Color(0xFF0B0716);
  static const onAccent = Color(0xFF032B27);
  static const accent = Color(0xFF2EE6D6); // neon turkuaz
  static const hot = Color(0xFFFF4FD8); // eşleşme pembesi
  static const text = Color(0xFFF6F2FF);
  static const textMuted = Color(0xFFA99BC9);

  /// İmza geçiş: mor -> turkuaz (beğen düğmesi, ilerleme, vurgular).
  static const signature = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  /// Mor ışıltı gölgesi.
  static List<BoxShadow> glow([Color color = primary]) => [
    BoxShadow(
      color: color.withValues(alpha: 0.45),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];
}

/// Değişken yazı tipinde kalınlık.
List<FontVariation> _w(double weight) => [FontVariation('wght', weight)];

TextTheme _textTheme() {
  TextStyle display(double size, double weight) => TextStyle(
    fontFamily: 'Bricolage',
    fontSize: size,
    fontWeight: FontWeight.w700,
    fontVariations: _w(weight),
    letterSpacing: -0.2,
    color: AppColors.text,
  );
  TextStyle body(double size, double weight, [Color color = AppColors.text]) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontVariations: _w(weight),
        color: color,
      );
  return TextTheme(
    displaySmall: display(36, 800),
    headlineMedium: display(28, 800),
    headlineSmall: display(24, 750),
    titleLarge: display(22, 700),
    titleMedium: body(16, 600),
    titleSmall: body(14, 600),
    bodyLarge: body(16, 400),
    bodyMedium: body(14, 400),
    bodySmall: body(12, 400, AppColors.textMuted),
    labelLarge: body(14, 600),
    labelMedium: body(12, 600),
    labelSmall: body(11, 600),
  );
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.text,
        secondary: AppColors.accent,
        onSecondary: AppColors.onAccent,
        secondaryContainer: const Color(0xFF0F3A44),
        onSecondaryContainer: AppColors.accent,
        tertiary: AppColors.hot,
        surface: AppColors.background,
        onSurface: AppColors.text,
        onSurfaceVariant: AppColors.textMuted,
        surfaceContainerLowest: AppColors.background,
        surfaceContainerLow: AppColors.card,
        surfaceContainer: AppColors.card,
        surfaceContainerHigh: AppColors.cardHigh,
        surfaceContainerHighest: AppColors.line,
        outline: AppColors.line,
        outlineVariant: AppColors.lineStrong,
      );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: 'Inter',
    textTheme: _textTheme(),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: _textTheme().titleLarge,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: AppColors.line),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontVariations: _w(s.contains(WidgetState.selected) ? 700 : 500),
          color: s.contains(WidgetState.selected)
              ? AppColors.text
              : AppColors.textMuted,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.card,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.textMuted,
        ),
        side: const WidgetStatePropertyAll(BorderSide(color: AppColors.line)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.line,
    ),
    chipTheme: ChipThemeData(
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.card,
      side: const BorderSide(color: AppColors.line),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.cardHigh,
      contentTextStyle: TextStyle(color: AppColors.text),
    ),
  );
}
