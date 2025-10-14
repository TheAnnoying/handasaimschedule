import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData getThemeData({required ColorScheme colorScheme}) {
  final isDark = colorScheme.brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.rubikTextTheme(),
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    hintColor: colorScheme.onSurfaceVariant,
    focusColor: colorScheme.primary,
    scaffoldBackgroundColor: isDark ? colorScheme.surface : colorScheme.primary.withValues(red: 0.95, green: 0.95, blue: 0.95),
    splashColor: colorScheme.primary.withValues(alpha: 0.1),
    highlightColor: colorScheme.primary.withValues(alpha: 0.1),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: colorScheme.surfaceContainer),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
    ),
  );
}