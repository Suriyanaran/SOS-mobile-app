import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Emergency Palette
  static const Color bgPrimary = Color(0xFF070A11);
  static const Color bgCard = Color(0xFF101827);
  static const Color bgInput = Color(0xFF111A2D);
  static const Color bgSubtle = Color(0xFF0D1424);

  static const Color redSos = Color(0xFFEF233C);
  static const Color redSosDark = Color(0xFF9D0208);
  static const Color redSosLight = Color(0xFFFF334B);
  static const Color redGlow = Color(0x66EF233C);

  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color greenSuccess = Color(0xFF10B981);
  static const Color blueTech = Color(0xFF0EA5E9);
  static const Color cyanAccent = Color(0xFF06B6D4);

  static const Color textMain = Color(0xFFF3F4F6);
  static const Color textSub = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0x1AFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      primaryColor: redSos,
      colorScheme: const ColorScheme.dark(
        primary: redSos,
        secondary: blueTech,
        surface: bgCard,
        error: redSos,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xEE070A11),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textMain),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: redSos,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInput,
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: redSos, width: 2),
        ),
      ),
    );
  }
}
