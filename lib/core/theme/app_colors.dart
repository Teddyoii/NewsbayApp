import 'package:flutter/material.dart';

/// Color tokens copied 1:1 from the design team's `Color.png` reference.
class AppColors {
  AppColors._();

  static const Color primary1 = Color(0xFF41AC85); // Primary / buttons
  static const Color primary2 = Color(0xFF093726); // Deep green (gradient end)
  static const Color white = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF6C6C78); // muted text
  static const Color onSurface = Color(0xFF131317); // headings / body text
  static const Color line = Color(0xFFE5E5E5); // borders / dividers
  static const Color critical = Color(0xFFEB5A5A);
  static const Color warning = Color(0xFFFABE3C);
  static const Color success = Color(0xFFA4D325);

  // The reference sheet labelled "Surface" with the same hex as "Success"
  // (#A4D325), which is almost certainly a copy/paste slip in the design
  // file — the swatch itself renders as a near-white card background.
  // Using a light neutral here so surfaces (cards, inputs) render as shown
  // in the login/dashboard mocks rather than lime green.
  static const Color surface = Color(0xFFF5F5F7);

  static const List<Color> heroGradient = [primary1, primary2];
}
