import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getThemeData({required ColorScheme colorScheme}) {
  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    fontFamily: GoogleFonts.rubik().fontFamily,
    colorScheme: colorScheme.harmonized(),
  );
}