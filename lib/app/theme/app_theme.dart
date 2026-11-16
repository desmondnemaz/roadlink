import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadlink/core/utils/responsive.dart';

// =============================================================================
// 1. CORE BRAND PALETTE (Dark Navy, Orange, White & Neutrals)
// =============================================================================

class AppPalette {
  AppPalette._();

  // Brand Navy (#0B1F3B primary)
  static const Color navy950 = Color(0xFF071426);
  static const Color navy900 = Color(0xFF0B1F3B);
  static const Color navy800 = Color(0xFF162E4C);
  static const Color navy700 = Color(0xFF24476B);
  static const Color navy600 = Color(0xFF355F87);

  // Brand Orange (#FF8C00 accent)
  static const Color orange50 = Color(0xFFFFF2E0);
  static const Color orange100 = Color(0xFFFFE0B2);
  static const Color orange300 = Color(0xFFFFB65C);
  static const Color orange500 = Color(0xFFFF8C00);
  static const Color orange600 = Color(0xFFC96300);
  static const Color orange700 = Color(0xFF9C4A00);

  // Brand Blue (#2563EB accent, #4A90E2 lighter button blue)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF2563EB);
  static const Color blue600 = Color(0xFF1D4ED8);
  static const Color buttonBlue = Color(0xFF4A90E2);

  // White & Neutrals
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFFBFCFE);
  static const Color neutral100 = Color(0xFFF3F5F8);
  static const Color neutral200 = Color(0xFFDCE1E8);
  static const Color neutral300 = Color(0xFFC4CFDE);
  static const Color neutral400 = Color(0xFF8792A2);
  static const Color neutral500 = Color(0xFF637084);
}

// =============================================================================
// 2. SEMANTIC THEME COLORS (Light & Dark via `context.colors`)
// =============================================================================

@immutable
class RoadlinkColors extends ThemeExtension<RoadlinkColors> {
  final Color backgroundCanvas;
  final Color surfaceDefault;
  final Color surfaceRaised;
  final Color surfaceInput;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color borderDefault;
  final Color actionPrimary;
  final Color actionOnPrimary;
  final Color actionPrimaryHover;
  final Color actionAccent;
  final Color actionOnAccent;
  final Color actionAccentHover;
  final Color linkDefault;
  final Color focusRing;
  final Color disabledBackground;
  final Color disabledText;
  final Color successForeground;
  final Color successBackground;
  final Color warningForeground;
  final Color warningBackground;
  final Color dangerForeground;
  final Color dangerBackground;
  final Color infoForeground;
  final Color infoBackground;

  const RoadlinkColors({
    required this.backgroundCanvas,
    required this.surfaceDefault,
    required this.surfaceRaised,
    required this.surfaceInput,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.borderDefault,
    required this.actionPrimary,
    required this.actionOnPrimary,
    required this.actionPrimaryHover,
    required this.actionAccent,
    required this.actionOnAccent,
    required this.actionAccentHover,
    required this.linkDefault,
    required this.focusRing,
    required this.disabledBackground,
    required this.disabledText,
    required this.successForeground,
    required this.successBackground,
    required this.warningForeground,
    required this.warningBackground,
    required this.dangerForeground,
    required this.dangerBackground,
    required this.infoForeground,
    required this.infoBackground,
  });

  static const RoadlinkColors light = RoadlinkColors(
    backgroundCanvas: AppPalette.neutral100,
    surfaceDefault: AppPalette.neutral0,
    surfaceRaised: AppPalette.neutral50,
    surfaceInput: AppPalette.neutral50,
    textPrimary: AppPalette.navy900,
    textSecondary: AppPalette.neutral500,
    textMuted: AppPalette.neutral500,
    borderDefault: AppPalette.neutral200,
    actionPrimary: AppPalette.navy900,
    actionOnPrimary: AppPalette.neutral0,
    actionPrimaryHover: AppPalette.navy800,
    actionAccent: AppPalette.buttonBlue,
    actionOnAccent: AppPalette.neutral0,
    actionAccentHover: AppPalette.blue400,
    linkDefault: AppPalette.blue600,
    focusRing: AppPalette.blue500,
    disabledBackground: AppPalette.neutral200,
    disabledText: AppPalette.neutral500,
    successForeground: Color(0xFF16734B),
    successBackground: Color(0xFFEAF7EF),
    warningForeground: Color(0xFF8A5400),
    warningBackground: Color(0xFFFFF4D6),
    dangerForeground: Color(0xFFB42318),
    dangerBackground: Color(0xFFFEF3F2),
    infoForeground: AppPalette.blue600,
    infoBackground: AppPalette.blue50,
  );

  static const RoadlinkColors dark = RoadlinkColors(
    backgroundCanvas: AppPalette.navy950,
    surfaceDefault: AppPalette.navy900,
    surfaceRaised: AppPalette.navy800,
    surfaceInput: AppPalette.navy800,
    textPrimary: AppPalette.neutral0,
    textSecondary: AppPalette.neutral300,
    textMuted: AppPalette.neutral400,
    borderDefault: AppPalette.navy600,
    actionPrimary: AppPalette.buttonBlue,
    actionOnPrimary: AppPalette.neutral0,
    actionPrimaryHover: AppPalette.blue400,
    actionAccent: AppPalette.buttonBlue,
    actionOnAccent: AppPalette.neutral0,
    actionAccentHover: AppPalette.blue400,
    linkDefault: AppPalette.blue400,
    focusRing: AppPalette.blue400,
    disabledBackground: AppPalette.navy800,
    disabledText: AppPalette.neutral400,
    successForeground: Color(0xFF6AD7A3),
    successBackground: Color(0xFF10352B),
    warningForeground: Color(0xFFFFC15C),
    warningBackground: Color(0xFF3B2C12),
    dangerForeground: Color(0xFFFF8A80),
    dangerBackground: Color(0xFF3B1C24),
    infoForeground: AppPalette.blue400,
    infoBackground: Color(0xFF0C2D48),
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppPalette.navy900, AppPalette.blue500],
  );

  @override
  RoadlinkColors copyWith() => this;

  @override
  RoadlinkColors lerp(ThemeExtension<RoadlinkColors>? other, double t) =>
      other is RoadlinkColors && t >= 0.5 ? other : this;
}

extension RoadlinkColorsContext on BuildContext {
  RoadlinkColors get colors =>
      Theme.of(this).extension<RoadlinkColors>() ?? RoadlinkColors.light;
}

// =============================================================================
// 3. SPACING, RADIUS & DIMENSIONS
// =============================================================================

class AppSpacing {
  AppSpacing._();
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20, s24 = 24;
  static const double s32 = 32, s40 = 40, s48 = 48, s64 = 64, s72 = 72, s96 = 96;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8, md = 12, lg = 16, xl = 24, panel = 32, pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius panelAll = BorderRadius.all(Radius.circular(panel));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

class AppSizes {
  AppSizes._();
  static const double controlSm = 40, controlDefault = 48, controlLg = 56;
  static const double buttonHeight = 48, buttonPaddingH = 20, touchMinimum = 44;
  static const double iconDefault = 24, borderDefaultWidth = 1, focusRingWidth = 3;
}

class AppLayout {
  AppLayout._();
  static const double mobilePageInset = 24, desktopWorkspaceInset = 36;
  static const double cardPadding = 24, cardGridGap = 24, sectionGap = 32;
  static const double labelToInput = 8;
}

class AppElevation {
  AppElevation._();
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: AppPalette.navy900.withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];
}

// =============================================================================
// 4. TYPOGRAPHY
// =============================================================================

class AppTypography {
  AppTypography._();
  static const String fontFamily = 'Inter';

  static TextStyle _s(double size, double line, FontWeight w, [double ls = 0]) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        height: line / size,
        fontWeight: w,
        letterSpacing: ls,
      );

  static final TextStyle display = _s(36, 42, FontWeight.w800, -0.8);
  static final TextStyle h1 = _s(26, 34, FontWeight.w800, -0.5);
  static final TextStyle h2 = _s(22, 30, FontWeight.w700, -0.4);
  static final TextStyle h3 = _s(18, 26, FontWeight.w700, -0.2);
  static final TextStyle title = _s(16, 22, FontWeight.w600, -0.1);
  static final TextStyle body = _s(14.5, 22, FontWeight.w400);
  static final TextStyle bodySmall = _s(13, 19, FontWeight.w400);
  static final TextStyle label = _s(13.5, 19, FontWeight.w600);
  static final TextStyle caption = _s(11.5, 16, FontWeight.w500);
  static final TextStyle button = _s(14, 20, FontWeight.w600);

  static TextStyle displayOf(BuildContext context) => Responsive.value(
        context,
        mobile: _s(28, 34, FontWeight.w800, -0.6),
        tablet: _s(32, 38, FontWeight.w800, -0.7),
        desktop: display,
      );

  static TextStyle h1Of(BuildContext context) => Responsive.value(
        context,
        mobile: _s(22, 28, FontWeight.w800, -0.4),
        tablet: _s(24, 32, FontWeight.w800, -0.5),
        desktop: _s(28, 36, FontWeight.w800, -0.6),
      );

  static TextStyle titleOf(BuildContext context) => Responsive.value(
        context,
        mobile: _s(15, 21, FontWeight.w600, -0.1),
        tablet: title,
        desktop: title,
      );

  static TextStyle bodyOf(BuildContext context) => Responsive.value(
        context,
        mobile: _s(13.5, 20, FontWeight.w400),
        tablet: body,
        desktop: body,
      );
}

// =============================================================================
// 5. MATERIAL THEME BUILDER (Light & Dark)
// =============================================================================

class AppTheme {
  AppTheme._();

  static final ThemeData light = _build(RoadlinkColors.light, Brightness.light);
  static final ThemeData dark = _build(RoadlinkColors.dark, Brightness.dark);

  static ThemeData _build(RoadlinkColors c, Brightness brightness) {
    OutlineInputBorder border(Color color, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: color, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: c.backgroundCanvas,
      canvasColor: c.backgroundCanvas,
      dividerColor: c.borderDefault,
      extensions: <ThemeExtension<dynamic>>[c],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.actionPrimary,
        onPrimary: c.actionOnPrimary,
        secondary: c.actionAccent,
        onSecondary: c.actionOnAccent,
        error: c.dangerForeground,
        onError: c.surfaceDefault,
        surface: c.surfaceDefault,
        onSurface: c.textPrimary,
        outline: c.borderDefault,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surfaceDefault,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppPalette.navy900,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        shape: Border(bottom: BorderSide(color: c.borderDefault)),
        titleTextStyle: AppTypography.title.copyWith(color: c.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceDefault,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: c.borderDefault),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceInput,
        constraints: const BoxConstraints(minHeight: AppSizes.controlDefault),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        hintStyle: AppTypography.body.copyWith(color: c.textSecondary),
        border: border(c.borderDefault),
        enabledBorder: border(c.borderDefault),
        focusedBorder: border(c.focusRing, 2),
        errorBorder: border(c.dangerForeground),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.actionPrimary,
          foregroundColor: c.actionOnPrimary,
          elevation: 0,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.actionAccent,
          foregroundColor: c.actionOnAccent,
          elevation: 0,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.borderDefault),
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTypography.button,
        ),
      ),
    );
  }
}
