import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getThemeData({required ColorScheme colorScheme}) {
  return ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.rubikTextTheme(),
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    splashColor: colorScheme.surfaceTint.withAlpha(25),
    highlightColor: colorScheme.surfaceTint.withAlpha(10),
  );
}