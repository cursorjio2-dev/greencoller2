import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {

  // static const String apiUrl = 'https://gc.internal.apstia.com/api/';
  // static const String folderUrl = 'https://gc.internal.apstia.com/';
  static const String apiUrl = 'https://greencollar.in/api/';
  static const String folderUrl = 'https://greencollar.in/';


  static String? uuidToken; // Make it static
  static Map<String, Map<String, String>> translations = {
    "Uttar Pradesh": {"en": "Uttar Pradesh", "hi": "उत्तर प्रदेश"},
    "Madhya Pradesh": {"en": "Madhya Pradesh", "hi": "मध्य प्रदेश"},
    "Hello": {"en": "Hello", "hi": "नमस्ते"},
    // Add more manual translations here...
  };
}

class AppColors {
  static const Color brand = Color(0xFF0E6805);
  static const Color brandDeep = Color(0xFF0A4D04);
  static const Color brandSoft = Color(0xFF9BC79A);
  static const Color brandTint = Color(0xFFEAF4E8);

  static const Color surface = Color(0xFFFAFBF7);
  static const Color surface2 = Color(0xFFF1F5EE);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE4EADF);

  static const Color ink = Color(0xFF152018);
  static const Color inkSoft = Color(0xFF5B6B5E);

  static const Color amberNotice = Color(0xFFF2B441);
  static const Color star = Color(0xFFFBBF24);

  // Button colors (app icon color)
  // static const Color button = Color(0xFF865E2A);
  // static const Color buttonBg = Color(0xFFF5EDE0);
  // static const Color buttonBorder = Color(0xFFD4B896);

  static const Color button = Color.fromRGBO(203, 157, 35, 1);
  static const Color buttonBg = Color(0xFFF5EDE0);
  static const Color buttonBorder = Color(0xFFD4B896);

  static const Gradient brandGradient = LinearGradient(
    begin: Alignment(-0.8, -0.6),
    end: Alignment(0.8, 0.6),
    colors: [Color(0xFF0E6805), Color(0xFF18843D)],
  );

  static const Gradient buttonGradient = LinearGradient(
    begin: Alignment(-0.8, -0.6),
    end: Alignment(0.8, 0.6),
    colors: [Color(0xFF865E2A), Color(0xFFA67C4E)],
  );
}

class AppRadii {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
  static const double full = 999.0;
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Color(0x400E6805), // rgba(14,104,5,0.25)
    offset: Offset(0, 8),
    blurRadius: 28,
    spreadRadius: -18,
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x4D0E6805), // rgba(14,104,5,0.30)
    offset: Offset(0, 10),
    blurRadius: 30,
    spreadRadius: -20,
  );

  static const BoxShadow fab = BoxShadow(
    color: Color(0x8C0E6805), // rgba(14,104,5,0.55)
    offset: Offset(0, 18),
    blurRadius: 40,
    spreadRadius: -14,
  );

  static const BoxShadow buttonSoft = BoxShadow(
    color: Color(0x40865E2A), // rgba(134,94,42,0.25)
    offset: Offset(0, 8),
    blurRadius: 28,
    spreadRadius: -18,
  );

  static const BoxShadow buttonCard = BoxShadow(
    color: Color(0x4D865E2A), // rgba(134,94,42,0.30)
    offset: Offset(0, 10),
    blurRadius: 30,
    spreadRadius: -20,
  );

  static const BoxShadow buttonFab = BoxShadow(
    color: Color(0x8C865E2A), // rgba(134,94,42,0.55)
    offset: Offset(0, 18),
    blurRadius: 40,
    spreadRadius: -14,
  );
}

class AppTypography {
  static TextStyle get display => GoogleFonts.plusJakartaSans(
        fontSize: 46,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.01 * 46,
        color: AppColors.ink,
      );

  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.01 * 22,
        color: AppColors.ink,
      );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.01 * 20,
        color: AppColors.ink,
      );

  static TextStyle get h3 => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.01 * 17,
        color: AppColors.ink,
      );

  static TextStyle get subhead => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: AppColors.inkSoft,
      );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.ink,
      );

  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: AppColors.inkSoft,
      );

  static TextStyle get micro => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.45,
        letterSpacing: 0.12 * 11,
        color: AppColors.inkSoft,
      );
}



