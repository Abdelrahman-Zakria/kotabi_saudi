import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/strings.dart';
import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/grade_badge.dart';
import 'grade_books_screen.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stages = StageModel.allStages;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.browseStages),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsBackgroundPainter(),
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
              return _StageSection(stage: stage);
            },
          ),
        ],
      ),
    );
  }
}

class _StageSection extends StatelessWidget {
  final StageModel stage;

  const _StageSection({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stage.displayName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: stage.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: 110,
            height: 3,
            decoration: BoxDecoration(
              color: stage.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stage.grades.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.79,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final grade = stage.grades[index];
              return _GradeCard(
                grade: grade,
                stageColor: stage.color,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final GradeModel grade;
  final Color stageColor;

  const _GradeCard({
    required this.grade,
    required this.stageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GradeBooksScreen(grade: grade),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryVeryLight,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryVeryLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: GradeBadge(
                      gradeNumber: grade.gradeNumber,
                      gradeId: grade.id,
                      color: stageColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: stageColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    grade.displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primaryVeryLight;
    const spacing = 12.0;
    const radius = 1.1;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
