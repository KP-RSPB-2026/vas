import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - dari desain Figma
  static const Color primary = Color(0xFF004B8C); // Biru
  static const Color secondary = Color(0xFF8DC73F); // Hijau
  
  // Status colors
  static const Color success = Color(0xFF8DC73F); // Hijau - on time
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color error = Color(0xFFC73F41); // Merah - late/early
  static const Color info = Color(0xFF004B8C); // Biru
  
  // Neutral colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color disabled = Color(0xFFE6E6E6); // Abu-abu tombol nonaktif
  
  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF58595B); // Teks tombol nonaktif
  static const Color textWhite = Colors.white;
  
  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = primary;
  
  // Button colors based on state
  static const Color buttonInArea = Color(0xFF004B8C); // Biru - can press
  static const Color buttonOutArea = Color(0xFFE6E6E6); // Abu-abu - disabled
  static const Color buttonSuccess = Color(0xFF8DC73F); // Hijau - completed
  static const Color buttonLate = Color(0xFFC73F41); // Merah - late/early
}
