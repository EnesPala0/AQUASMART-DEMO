import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color white = Colors.white;
  static const Color greyText = Color(0xFF757575);
  static const Color darkText = Color(0xFF212121);
  static const Color efficiencyGreen = Color(0xFF4CAF50);
}

class AppTextStyles {
  static TextStyle get headline => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      );

  static TextStyle get title => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      );

  static TextStyle get body => GoogleFonts.roboto(
        fontSize: 14,
        color: AppColors.greyText,
      );

  static TextStyle get temperature => GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      );
      
  static TextStyle get cardValue => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryBlue,
  );
  
  static TextStyle get cardLabel => GoogleFonts.roboto(
    fontSize: 12,
    color: AppColors.greyText,
  );
}
