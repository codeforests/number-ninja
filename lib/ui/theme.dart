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

  // Drawn visuals (PRC-10).
  static const red = Color(0xFFE53935);
  static const blue = Color(0xFF1E88E5);
  static const yellow = Color(0xFFFDD835);
  static const green = Color(0xFF43A047);
  static const orange = Color(0xFFFB8C00);
  static const brown = Color(0xFF8D6E63);
  static const coinGold = Color(0xFFE0B341);
  static const coinSilver = Color(0xFFC9CDD2);
  static const wood = Color(0xFFF3D9A4);
  static const shade = Color(0xFF7E86E8); // shaded fraction parts, bar units

  // Locked School topics (PRC-14).
  static const locked = Color(0xFFEDEDF3);
  static const lockedText = Color(0xFF55556A);

  // Dashboard tracks and charts (PAR-05, PAR-06).
  static const trackP1 = Color(0xFF1E88E5);
  static const trackP2 = Color(0xFFFF8A00);
  static const trackOly = Color(0xFF8E24AA);
  static const chartGrid = Color(0xFFDDDDE6);

  // Child screen backgrounds, top and bottom of the gradient (NFR-10).
  // Light enough that ink text keeps its contrast.
  static const bgHomeTop = Color(0xFFFFF3C4); // sunny yellow
  static const bgHomeBottom = Color(0xFFFFE0EC); // soft pink
  static const bgSchoolTop = Color(0xFFD9EEFF); // sky
  static const bgSchoolBottom = Color(0xFFE0F6E6); // mint
  static const bgOlyTop = Color(0xFFECE0FF); // lilac
  static const bgOlyBottom = Color(0xFFFFE4F2); // pink
  static const bgShape = Color(0x66FFFFFF); // faint white shapes

  /// Confetti on SCR-05 (NFR-10).
  static const confetti = [red, blue, yellow, green, orange, trackOly, sun];
}

abstract final class AppRadii {
  static const card = 24.0;
  static const button = 20.0;
  static const confetti = 3.0;
}

abstract final class AppSizes {
  /// Minimum tap target on child screens (NFR-03).
  static const minTap = 64.0;
  static const pinKey = 72.0;
  static const gap = 16.0;

  /// Trend chart plot height and dot radius on parent screens.
  static const chartHeight = 180.0;
  static const chartDot = 4.0;
  static const chartLine = 2.5;

  /// Badge icon on SCR-05 and SCR-06, and the small one on SCR-02.
  static const badge = 96.0;
  static const badgeSmall = 48.0;
}

abstract final class AppMotion {
  /// The pop-in of a new badge on SCR-05 (BDG-02).
  static const badgePop = Duration(milliseconds: 600);

  /// The confetti on SCR-05 (NFR-10).
  static const celebration = Duration(milliseconds: 2500);

  /// Each result star pops in this long after the one before (NFR-10).
  static const starPop = Duration(milliseconds: 350);
}

abstract final class AppText {
  static const title = 40.0;
  static const heading = 28.0;
  static const body = 22.0;
  static const small = 20.0; // smallest text on child screens (NFR-03)

  /// Parent screens only: chart axis labels and table details.
  static const chartLabel = 14.0;
  static const parentBody = 16.0;
}

/// PDF progress report (FEAT-07) sizes, in points. Colours come from
/// [AppColors] through `pdfColor` in the report code.
abstract final class AppPdf {
  static const margin = 56.7; // 2 cm
  static const title = 20.0;
  static const heading = 13.0;
  static const body = 10.0;
  static const small = 8.0;
  static const chartHeight = 140.0;
  static const chartLine = 1.5;
  static const chartDot = 2.0;
  static const gridLine = 0.5;
  static const gap = 12.0;
  static const cellPadding = 4.0;
  static const axisWidth = 36.0;
  static const axisGap = 4.0;
  static const swatchWidth = 10.0;
  static const swatchHeight = 3.0;
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
