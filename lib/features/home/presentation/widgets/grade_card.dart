import 'package:flutter/material.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/grade_badge.dart';
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
                padding: const EdgeInsets.all(8),
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
    final String? mappedId = _mapToGradeId(grade.id);
    final int gradeNum = _extractGradeNumber(grade.title);
    final Color color = _getGradeColor(grade.title);

    return GradeBadge(
      gradeNumber: gradeNum,
      color: color,
      gradeId: mappedId,
    );
  }

  String? _mapToGradeId(String firestoreId) {
    final mapping = {
      '2c320eee84b1f8f59cc515fa51a9d9ce': 'grade1',
      'c63cc3c4bc33e35b85613f1f2eb3d562': 'grade2',
      '9651505f1b57ed01c33eb6eafaa5b99b': 'grade3',
      'cccea53d3a73dd23a5f1732282e8e9ca': 'grade4',
      '0d6843edfb9dc0e21618840d87d8e52d': 'grade5',
      'c4049fdb4696c4e7839260b1b2de0c24': 'grade6',
      'f6f2cbbaa3ddfc0287830dfec6c6f804': 'grade7',
      '95671efdb0eb2723aa1e754a5ad7a0f9': 'grade8',
      '4f4183677e0fb0d83d7c6cac416b9ebe': 'grade9',
      '2f37138dbaa3c1b7426b5c859af01ba0': 'grade10',
      '180099da8ee785bba755692fdf2d1269': 'grade11',
      '9e7ead7f654c61852b2597f46c3cf214': 'grade12',
    };
    return mapping[firestoreId];
  }

  int _extractGradeNumber(String title) {
    if (title.contains('الاول')) return 1;
    if (title.contains('الثاني')) return 2;
    if (title.contains('الثالث')) return 3;
    if (title.contains('الرابع')) return 4;
    if (title.contains('الخامس')) return 5;
    if (title.contains('السادس')) return 6;
    return 1;
  }

  Color _getGradeColor(String title) {
    if (title.contains('ابتدائي')) return const Color(0xFF22C55E);
    if (title.contains('متوسط')) return const Color(0xFF5B7FA6);
    if (title.contains('ثانوي')) return const Color(0xFF8B5CF6);
    return const Color(0xFF22C55E);
  }
}
