import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/educational_node.dart';

class GradeCard extends StatelessWidget {
  final EducationalNode grade;
  final VoidCallback onTap;

  const GradeCard({
    super.key,
    required this.grade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: _buildGradeIcon(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    grade.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeIcon() {
    // Generate a unique colorful background and icon based on grade title
    final Color color = _getGradeColor(grade.title);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getGradeIconData(grade.title),
        size: 50,
        color: color,
      ),
    );
  }

  Color _getGradeColor(String title) {
    if (title.contains('الاول')) return Colors.blue;
    if (title.contains('الثاني')) return Colors.orange;
    if (title.contains('الثالث')) return Colors.green;
    if (title.contains('الرابع')) return Colors.purple;
    if (title.contains('الخامس')) return Colors.red;
    if (title.contains('السادس')) return Colors.teal;
    return AppTheme.primaryColor;
  }

  IconData _getGradeIconData(String title) {
    if (title.contains('ابتدائي')) return Icons.face;
    if (title.contains('متوسط')) return Icons.school;
    if (title.contains('ثانوي')) return Icons.menu_book;
    return Icons.book;
  }
}
