import 'package:flutter/material.dart';

ThemeData getThemeData({required ColorScheme colorScheme}) {
  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    splashColor: colorScheme.surfaceTint.withAlpha(25),
    highlightColor: colorScheme.surfaceTint.withAlpha(10),
  );
}