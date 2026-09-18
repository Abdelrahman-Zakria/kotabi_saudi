import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/strings.dart';
import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/services/mnhaji_source_catalog_service.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/grade_badge.dart';
import 'mnhaji_books_screen.dart';

class MnhajiBooksGradesScreen extends StatefulWidget {
  const MnhajiBooksGradesScreen({super.key});

  @override
  State<MnhajiBooksGradesScreen> createState() =>
      _MnhajiBooksGradesScreenState();
}

class _MnhajiBooksGradesScreenState extends State<MnhajiBooksGradesScreen> {
  final MnhajiSourceCatalogService _service =
      MnhajiSourceCatalogService.manhajiBooks;
  late final Future<List<MnhajiGradeEntry>> _gradesFuture =
      _service.fetchGrades();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(AppStrings.mnhajiBooks),
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
          FutureBuilder<List<MnhajiGradeEntry>>(
            future: _gradesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final entries = snapshot.data ?? const [];
              if (entries.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد محتويات حالياً',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                itemCount: entries.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _GradeCard(
                    entry: entry,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MnhajiBooksScreen(grade: entry.grade),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final MnhajiGradeEntry entry;
  final VoidCallback onTap;

  const _GradeCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final grade = entry.grade;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFEAFBF1),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
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
                      color: const Color(0xFFF7FDF9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: GradeBadge(
                      gradeNumber: grade.gradeNumber,
                      gradeId: grade.id,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    grade.displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
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
    final paint = Paint()..color = const Color(0xFFEAFBF1);
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
