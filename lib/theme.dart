import 'package:material_ui/material_ui.dart';

/// Uygulama renkleri (tasarım paleti: koyu sinema).
class AppColors {
  const AppColors._();

  static const background = Color(0xFF0E0D12); // zemin
  static const card = Color(0xFF1A1821); // kart
  static const cardHigh = Color(0xFF24212D); // seçili / yükseltilmiş kart
  static const line = Color(0xFF2E2A38); // çizgi
  static const primary = Color(0xFFFF5A66); // perde kırmızısı
  static const onPrimary = Color(0xFF1A0A0C); // kırmızı üstünde koyu yazı
  static const accent = Color(0xFFFFC857); // mısır sarısı
  static const text = Color(0xFFF4F1EA);
  static const textMuted = Color(0xFFA39FAE);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: const Color(0xFF4A1A20),
    onPrimaryContainer: AppColors.text,
    secondary: AppColors.accent,
    onSecondary: AppColors.onPrimary,
    secondaryContainer: const Color(0xFF3D3016),
    onSecondaryContainer: AppColors.accent,
    surface: AppColors.background,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.card,
    surfaceContainer: AppColors.card,
    surfaceContainerHigh: AppColors.cardHigh,
    surfaceContainerHighest: AppColors.line,
    outline: AppColors.line,
    outlineVariant: AppColors.line,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.card,
      indicatorColor: Color(0xFF4A1A20),
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: AppColors.text)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.cardHigh,
      contentTextStyle: TextStyle(color: AppColors.text),
    ),
  );
}
