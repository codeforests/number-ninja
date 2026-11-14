import 'package:material_ui/material_ui.dart';

/// The only place colours, radii and sizes are defined (design §6).
abstract final class AppColors {
  static const ninja = Color(0xFF2E3192); // deep indigo
  static const ninjaLight = Color(0xFFE8E9FF);
  static const sun = Color(0xFFFF8A00); // orange accent
  static const leaf = Color(0xFF1B9E4B); // right answer
  static const berry = Color(0xFFD7263D); // wrong answer
  static const ink = Color(0xFF1C1C28);
  static const paper = Color(0xFFFFFBF2);
  static const muted = Color(0xFF6B6B80);
  static const card = Color(0xFFFFFFFF);
}

abstract final class AppRadii {
  static const card = 24.0;
  static const button = 20.0;
}

abstract final class AppSizes {
  /// Minimum tap target on child screens (NFR-03).
  static const minTap = 64.0;
  static const pinKey = 72.0;
  static const gap = 16.0;
}

abstract final class AppText {
  static const title = 40.0;
  static const heading = 28.0;
  static const body = 22.0;
  static const small = 20.0; // smallest text on child screens (NFR-03)
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.ninja,
    primary: AppColors.ninja,
    secondary: AppColors.sun,
    error: AppColors.berry,
    surface: AppColors.paper,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.paper,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: AppText.title,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      headlineSmall: TextStyle(
        fontSize: AppText.heading,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: TextStyle(fontSize: AppText.body, color: AppColors.ink),
      bodyMedium: TextStyle(fontSize: AppText.small, color: AppColors.ink),
      labelLarge: TextStyle(
        fontSize: AppText.body,
        fontWeight: FontWeight.w700,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(AppSizes.minTap * 3, AppSizes.minTap),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
      ),
    ),
  );
}
