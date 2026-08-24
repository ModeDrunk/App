import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SnackbarService {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.success);
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.error);
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(context, message, AppColors.info);
  }

  static void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
