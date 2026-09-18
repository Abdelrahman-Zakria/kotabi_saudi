import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppHelpers {
  /// Show a snackbar message
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final safeMessage =
        message.length > 140 ? '${message.substring(0, 140)}...' : message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          safeMessage,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Colors.white,
          ),
          textAlign: TextAlign.right,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Format page count
  static String formatPageCount(int pages) {
    return '$pages صفحة';
  }

  /// Get subject icon
  static IconData getSubjectIcon(String subject) {
    final subjectLower = subject.toLowerCase();
    if (subjectLower.contains('قرآن') ||
        subjectLower.contains('إسلام') ||
        subjectLower.contains('توحيد') ||
        subjectLower.contains('فقه')) {
      return Icons.mosque_rounded;
    } else if (subjectLower.contains('رياضيات') ||
        subjectLower.contains('math')) {
      return Icons.calculate_rounded;
    } else if (subjectLower.contains('علوم') ||
        subjectLower.contains('science')) {
      return Icons.science_rounded;
    } else if (subjectLower.contains('عربية') ||
        subjectLower.contains('arabic')) {
      return Icons.translate_rounded;
    } else if (subjectLower.contains('إنجليزية') ||
        subjectLower.contains('english')) {
      return Icons.language_rounded;
    } else if (subjectLower.contains('حاسب') ||
        subjectLower.contains('computer')) {
      return Icons.computer_rounded;
    } else if (subjectLower.contains('فيزياء') ||
        subjectLower.contains('physics')) {
      return Icons.electric_bolt_rounded;
    } else if (subjectLower.contains('كيمياء') ||
        subjectLower.contains('chemistry')) {
      return Icons.biotech_rounded;
    } else if (subjectLower.contains('أحياء') ||
        subjectLower.contains('biology')) {
      return Icons.eco_rounded;
    } else if (subjectLower.contains('تاريخ') ||
        subjectLower.contains('history')) {
      return Icons.history_edu_rounded;
    } else if (subjectLower.contains('جغرافيا') ||
        subjectLower.contains('geography')) {
      return Icons.public_rounded;
    } else if (subjectLower.contains('وطنية') ||
        subjectLower.contains('national')) {
      return Icons.flag_rounded;
    } else {
      return Icons.book_rounded;
    }
  }

  /// Get stage color
  static Color getStageColor(String stage) {
    if (stage.contains('ابتدائي') || stage.contains('primary')) {
      return AppColors.primarySchoolColor;
    } else if (stage.contains('متوسط') || stage.contains('middle')) {
      return AppColors.middleSchoolColor;
    } else if (stage.contains('ثانو') || stage.contains('high')) {
      return AppColors.highSchoolColor;
    } else if (stage.contains('روضة') || stage.contains('kg')) {
      return AppColors.kgColor;
    }
    return AppColors.primary;
  }
}
