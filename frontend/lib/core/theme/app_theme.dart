import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColors
// ─────────────────────────────────────────────────────────────────────────────

/// Centralised colour palette for AquaSense.
///
/// Rule: no widget file may contain a raw `Color(0x...)` literal.
/// Every colour lives here with a descriptive name and doc comment.
class AppColors {
  AppColors._(); // non-instantiable

  // ── Brand teal ─────────────────────────────────────────────────────────────
  /// Primary brand colour — buttons, active icons, focused borders.
  static const teal      = Color(0xFF1B6B5A);
  static const tealDark  = Color(0xFF0D4A3E);
  static const tealLight = Color(0xFF2A8A72);

  // ── Accent mints / pinks ───────────────────────────────────────────────────
  /// Mint — illustration pill cards, step-indicator inactive fill.
  static const mint      = Color(0xFFB2F5EA);
  /// Lighter mint — disabled button background, blob shapes.
  static const mintLight = Color(0xFFD4FAF2);
  /// Pink pastel — decorative blobs, back-button circle.
  static const pinkLight = Color(0xFFFCE7F3);

  // ── Neutral surfaces ────────────────────────────────────────────────────────
  static const white        = Color(0xFFFFFFFF);
  /// App scaffold background — very light grey so cards pop.
  static const background   = Color(0xFFFAFAFA);
  /// Surface used for search bars and secondary containers.
  static const surfaceGrey  = Color(0xFFF3F4F6);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const textDark = Color(0xFF1A1A2E);
  static const textGrey = Color(0xFF6B7280);

  // ── Borders ─────────────────────────────────────────────────────────────────
  static const borderColor = Color(0xFFE5E7EB);

  // ── Illustration scatter dots ───────────────────────────────────────────────
  static const dotGreen  = Color(0xFF10B981);
  static const dotMaroon = Color(0xFF7F1D1D);

  // ── Semantic risk colours ───────────────────────────────────────────────────
  // Each risk level exposes a foreground (text/icon) and background (badge fill).
  // Use these in [RiskBadge], [TrendIcon], and anywhere risk is visualised.

  /// High risk — red family.
  static const riskHighFg = Color(0xFFBE123C);
  static const riskHighBg = Color(0xFFFFE4E6);

  /// Medium risk — amber family.
  static const riskMediumFg = Color(0xFFB45309);
  static const riskMediumBg = Color(0xFFFEF9C3);

  /// Low risk — green family.
  static const riskLowFg = Color(0xFF15803D);
  static const riskLowBg = Color(0xFFDCFCE7);

  // ── Trend colours ───────────────────────────────────────────────────────────
  /// Rising reading — green.
  static const trendUp     = Color(0xFF15803D);
  /// Falling reading — red.
  static const trendDown   = Color(0xFFBE123C);
  /// Stable reading — grey.
  static const trendStable = Color(0xFF6B7280);

  // ── Misc UI ─────────────────────────────────────────────────────────────────
  /// Purple FAB colour used for the AI assistant button.
  static const aiFab = Color(0xFF7C2D8E);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextStyles  (named semantic slots)
// ─────────────────────────────────────────────────────────────────────────────

/// Semantic text style constants built on top of the DM Sans font.
///
/// Prefer these over raw [TextStyle] literals in widget files.
/// The names mirror Flutter's [TextTheme] slots so you can recognise
/// the hierarchy at a glance without memorising pixel sizes.
class AppTextStyles {
  AppTextStyles._();

  // ── Display / hero ──────────────────────────────────────────────────────────
  /// Large screen titles, e.g. "Welcome Meggie 👋".
  static final displayLarge = GoogleFonts.dmSans(
    fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.2,
  );

  // ── Headlines ───────────────────────────────────────────────────────────────
  /// Section headings, e.g. "Recent Sensors", "Sensors" page title.
  static final headlineMedium = GoogleFonts.dmSans(
    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3,
  );

  /// Card / sheet titles, e.g. sensor reading value, sheet header.
  static final headlineSmall = GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark,
  );

  // ── Titles ───────────────────────────────────────────────────────────────────
  /// Auth screen titles ("Create Account", "Welcome back").
  static final titleLarge = GoogleFonts.dmSans(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark,
  );

  /// List item titles, wizard section labels.
  static final titleMedium = GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark,
  );

  /// Sensor ID label, badge text.
  static final titleSmall = GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGrey,
  );

  // ── Body ─────────────────────────────────────────────────────────────────────
  /// Standard readable body copy.
  static final bodyLarge = GoogleFonts.dmSans(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textDark,
  );

  /// Secondary body — location strings, AI insight snippets.
  static final bodyMedium = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textGrey, height: 1.5,
  );

  /// Tertiary / captions — timestamps, helper text.
  static final bodySmall = GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textGrey,
  );

  // ── Labels ───────────────────────────────────────────────────────────────────
  /// Bold field labels above text inputs.
  static final labelLarge = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark,
  );

  /// Button text.
  static final labelMedium = GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white,
  );

  /// Nav bar labels, badge text.
  static final labelSmall = GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textGrey,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme
// ─────────────────────────────────────────────────────────────────────────────

/// Global [ThemeData] applied to the root [MaterialApp].
///
/// Key decisions:
/// • [inputDecorationTheme] is defined once here — [AppTextField],
///   [SearchBarWidget], and [_WizardTextField] all inherit it automatically,
///   ensuring a single source of truth for border radius, padding, colours.
/// • [textTheme] maps Flutter's named slots to [AppTextStyles] so any widget
///   can call `Theme.of(context).textTheme.bodyMedium` instead of
///   hard-coding sizes and weights.
class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        primary:   AppColors.teal,
        surface:   AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );

    return base.copyWith(
      // ── Text theme ──────────────────────────────────────────────────────────
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge:   AppTextStyles.displayLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall:  AppTextStyles.headlineSmall,
        titleLarge:     AppTextStyles.titleLarge,
        titleMedium:    AppTextStyles.titleMedium,
        titleSmall:     AppTextStyles.titleSmall,
        bodyLarge:      AppTextStyles.bodyLarge,
        bodyMedium:     AppTextStyles.bodyMedium,
        bodySmall:      AppTextStyles.bodySmall,
        labelLarge:     AppTextStyles.labelLarge,
        labelMedium:    AppTextStyles.labelMedium,
        labelSmall:     AppTextStyles.labelSmall,
      ),

      // ── Input decoration theme ───────────────────────────────────────────────
      // Applied automatically to every TextField / TextFormField in the app.
      // Widgets only need to set hint text, suffix icons, or prefixIcon —
      // borders, fill colour, and padding come from here.
      inputDecorationTheme: InputDecorationTheme(
        filled:          true,
        fillColor:       AppColors.white,
        hintStyle:       AppTextStyles.bodyLarge.copyWith(color: AppColors.textGrey),
        contentPadding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        // Default (unfocused) border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.borderColor),
        ),
        // Focused border — teal highlight
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.riskHighFg, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.riskHighFg, width: 2),
        ),
      ),

      // ── Elevated button theme ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:         AppColors.teal,
          foregroundColor:         AppColors.white,
          disabledBackgroundColor: AppColors.mintLight,
          disabledForegroundColor: AppColors.teal,
          minimumSize:             const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: AppTextStyles.labelMedium,
        ),
      ),

      // ── Card theme ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:        AppColors.white,
        elevation:    0,
        shape:        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:         const BorderSide(color: AppColors.borderColor),
        ),
        margin:       const EdgeInsets.only(bottom: 12),
      ),

      // ── Bottom app bar ───────────────────────────────────────────────────────
      // bottomAppBarTheme: const BottomAppBarTheme(
      //   color:   AppColors.white,
      //   elevation: 8,
      // ),
    );
  }
}