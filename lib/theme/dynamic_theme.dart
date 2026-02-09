import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getThemeData({required ColorScheme colorScheme}) {
  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    fontFamily: GoogleFonts.huninn().fontFamily,
    colorScheme: colorScheme,
    splashColor: colorScheme.surfaceTint.withOpacity(0.1),
    highlightColor: colorScheme.surfaceTint.withOpacity(0.1),
  );
}