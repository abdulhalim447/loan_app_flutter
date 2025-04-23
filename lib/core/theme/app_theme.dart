import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color authorityBlue = Color(0xFF003366);
  static const Color trustCyan = Color(0xFF00CCFF);
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color textDark = Color(0xFF2A2D3D);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF476F);
  static const Color neutral50 = Color(0xFFF8F9FA);
  static const Color neutral100 = Color(0xFFF1F3F5);
  static const Color neutral200 = Color(0xFFE9ECEF);
  static const Color neutral300 = Color(0xFFDEE2E6);
  static const Color neutral400 = Color(0xFFCED4DA);
  static const Color neutral500 = Color(0xFFADB5BD);
  static const Color neutral600 = Color(0xFF868E96);
  static const Color neutral700 = Color(0xFF495057);
  static const Color neutral800 = Color(0xFF343A40);
  static const Color neutral900 = Color(0xFF212529);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [authorityBlue, trustCyan],
    stops: [0.0, 1.0],
    transform: GradientRotation(0.785398), // 45° in radians
  );

  // Material 3 ColorScheme
  static ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: authorityBlue,
    onPrimary: Colors.white,
    primaryContainer: authorityBlue.withOpacity(0.1),
    onPrimaryContainer: authorityBlue,
    secondary: trustCyan,
    onSecondary: Colors.white,
    secondaryContainer: trustCyan.withOpacity(0.1),
    onSecondaryContainer: trustCyan.withOpacity(0.7),
    tertiary: success,
    onTertiary: Colors.white,
    tertiaryContainer: success.withOpacity(0.1),
    onTertiaryContainer: success.withOpacity(0.7),
    error: error,
    onError: Colors.white,
    errorContainer: error.withOpacity(0.1),
    onErrorContainer: error,
    surface: Colors.white,
    onSurface: textDark,
    surfaceContainerHighest: neutral100,
    onSurfaceVariant: neutral700,
    outline: neutral400,
    shadow: Colors.black.withOpacity(0.1),
    inverseSurface: textDark,
    onInverseSurface: Colors.white,
    inversePrimary: trustCyan,
    surfaceTint: authorityBlue.withOpacity(0.05),
  );

  // Text Themes
  static TextTheme _createTextTheme({bool isBangla = false}) {
    if (isBangla) {
      return TextTheme(
        displayLarge: GoogleFonts.hindSiliguri(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
          height: 1.12,
          color: textDark,
        ),
        displayMedium: GoogleFonts.hindSiliguri(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          height: 1.16,
          color: textDark,
        ),
        displaySmall: GoogleFonts.hindSiliguri(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          height: 1.22,
          color: textDark,
        ),
        headlineLarge: GoogleFonts.hindSiliguri(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          height: 1.25,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.hindSiliguri(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          height: 1.29,
          color: textDark,
        ),
        headlineSmall: GoogleFonts.hindSiliguri(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          height: 1.33,
          color: textDark,
        ),
        titleLarge: GoogleFonts.hindSiliguri(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
          color: textDark,
        ),
        titleMedium: GoogleFonts.hindSiliguri(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.5,
          color: textDark,
        ),
        titleSmall: GoogleFonts.hindSiliguri(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
          color: textDark,
        ),
        labelLarge: GoogleFonts.hindSiliguri(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: textDark,
        ),
        labelMedium: GoogleFonts.hindSiliguri(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
          color: textDark,
        ),
        labelSmall: GoogleFonts.hindSiliguri(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.hindSiliguri(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          height: 1.5,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.hindSiliguri(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 1.43,
          color: textDark,
        ),
        bodySmall: GoogleFonts.hindSiliguri(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          height: 1.33,
          color: textDark,
        ),
      );
    }

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.25,
        height: 1.12,
        color: textDark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.16,
        color: textDark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.22,
        color: textDark,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.25,
        color: textDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.29,
        color: textDark,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.33,
        color: textDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: textDark,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
        color: textDark,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: textDark,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: textDark,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: textDark,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
        height: 1.5,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        height: 1.43,
        color: textDark,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        height: 1.33,
        color: textDark,
      ),
    );
  }

  // Theme Data
  static ThemeData lightTheme({bool useBanglaFont = true}) {
    final TextTheme textTheme = _createTextTheme(isBangla: useBanglaFont);
    final String? fontFamily = useBanglaFont
        ? GoogleFonts.hindSiliguri().fontFamily
        : GoogleFonts.inter().fontFamily;

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      brightness: Brightness.light,
      textTheme: textTheme,
      fontFamily: fontFamily,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: textDark),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: authorityBlue,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: authorityBlue,
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: authorityBlue, width: 1.5),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: authorityBlue,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutral100,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: authorityBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: neutral600),
        hintStyle: textTheme.bodyMedium?.copyWith(color: neutral500),
        errorStyle: textTheme.bodySmall?.copyWith(color: error),
        prefixIconColor: neutral600,
        suffixIconColor: neutral600,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: authorityBlue,
        unselectedItemColor: neutral600,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: authorityBlue,
        unselectedLabelColor: neutral600,
        indicatorColor: authorityBlue,
        labelStyle:
            textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelMedium,
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return authorityBlue;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(color: neutral400, width: 1.5),
      ),

      // Radio Button Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return authorityBlue;
          }
          return neutral400;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return authorityBlue;
          }
          return neutral200;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return authorityBlue.withOpacity(0.5);
          }
          return neutral400;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: authorityBlue,
        inactiveTrackColor: neutral200,
        thumbColor: authorityBlue,
        overlayColor: authorityBlue.withOpacity(0.2),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: authorityBlue,
        circularTrackColor: neutral200,
        linearTrackColor: neutral200,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: neutral100,
        disabledColor: neutral200,
        selectedColor: authorityBlue.withOpacity(0.1),
        secondarySelectedColor: authorityBlue.withOpacity(0.1),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: authorityBlue),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: neutral300),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        modalElevation: 16,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: trustCyan,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: neutral200,
        thickness: 1,
        space: 1,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // Financial Text Style (for numbers)
  static TextStyle financialTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color ?? textDark,
    );
  }
}
