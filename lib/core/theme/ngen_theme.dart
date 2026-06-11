import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual identity aligned with [ngentours.com] (Open Sans + #7225d7).
class NgenTheme {
  NgenTheme._();

  static const String fontFamily = 'Open Sans';

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.font_black,
      error: AppColors.red,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
    );

    final textTheme = _textTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.font_black,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.font_black, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black26,
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.openSans(color: AppColors.textMuted, fontSize: 14),
        hintStyle: GoogleFonts.openSans(color: AppColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.openSans(color: AppColors.white, fontSize: 14),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.font_light,
        labelStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 13),
        indicatorColor: AppColors.primary,
        dividerColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE8E8EC), thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.navSelected,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    final openSans = GoogleFonts.openSansTextTheme(base);

    return openSans.copyWith(
      displayLarge: GoogleFonts.openSans(
        fontWeight: FontWeight.w300,
        fontSize: 48,
        height: 1.15,
        color: AppColors.font_black,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.openSans(
        fontWeight: FontWeight.w300,
        fontSize: 36,
        height: 1.2,
        color: AppColors.font_black,
      ),
      headlineLarge: GoogleFonts.openSans(
        fontWeight: FontWeight.w600,
        fontSize: 28,
        height: 1.25,
        color: AppColors.font_black,
      ),
      headlineMedium: GoogleFonts.openSans(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.3,
        color: AppColors.font_black,
      ),
      headlineSmall: GoogleFonts.openSans(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.35,
        color: AppColors.font_bold,
      ),
      titleLarge: GoogleFonts.openSans(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.35,
        color: AppColors.font_light,
      ),
      titleMedium: GoogleFonts.openSans(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.4,
        color: AppColors.font_bold,
      ),
      titleSmall: GoogleFonts.openSans(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.font_bold,
      ),
      bodyLarge: GoogleFonts.openSans(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
        color: AppColors.font_bold,
      ),
      bodyMedium: GoogleFonts.openSans(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.43,
        color: AppColors.font_light,
      ),
      bodySmall: GoogleFonts.openSans(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.4,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.openSans(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 0.6,
        color: AppColors.secondary,
      ),
      labelMedium: GoogleFonts.openSans(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: AppColors.font_light,
      ),
      labelSmall: GoogleFonts.openSans(
        fontWeight: FontWeight.w500,
        fontSize: 10,
        color: AppColors.textMuted,
      ),
    );
  }

  /// Landing-style login / auth background (#c7a4ff).
  static BoxDecoration loginBackground() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accentLight,
            Color(0xFFE8D4FF),
            AppColors.white,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      );

  /// Bottom nav label (uppercase, compact — matches web `.font-ngen`).
  static TextStyle navLabel(BuildContext context, {required bool selected}) {
    final base = Theme.of(context).textTheme.labelLarge!;
    return base.copyWith(
      fontSize: 9,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      color: selected ? AppColors.primary : AppColors.secondary,
      letterSpacing: 0.4,
    );
  }

  /// Section headers on Explore / lists.
  static TextStyle sectionHeader(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!;
  }
}
