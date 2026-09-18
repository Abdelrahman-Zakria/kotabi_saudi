import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import 'package:kotabi_saudi/core/models/kotbi_1447_models.dart';
import 'package:kotabi_saudi/core/services/kotbi_1447_catalog_service.dart';
import 'kotbi_1447_subjects_screen.dart';

class Kotbi1447GradesScreen extends StatefulWidget {
  const Kotbi1447GradesScreen({super.key});

  @override
  State<Kotbi1447GradesScreen> createState() => _Kotbi1447GradesScreenState();
}

class _Kotbi1447GradesScreenState extends State<Kotbi1447GradesScreen> {
  late final Future<List<Kotbi1447Grade>> _gradesFuture =
      Kotbi1447CatalogService.instance.fetchGrades();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('كتبي 1447'),
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
          FutureBuilder<List<Kotbi1447Grade>>(
            future: _gradesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final grades = snapshot.data ?? const [];
              if (grades.isEmpty) {
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
                itemCount: grades.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final grade = grades[index];
                  return _GradeCard(
                    grade: grade,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Kotbi1447SubjectsScreen(grade: grade),
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
  final Kotbi1447Grade grade;
  final VoidCallback onTap;

  const _GradeCard({
    required this.grade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appGrade = grade.appGrade;

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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        grade.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            _buildFallbackImage(appGrade),
                      ),
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
                    appGrade?.displayName ?? grade.name,
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

  Widget _buildFallbackImage(GradeModel? grade) {
    return Center(
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            (grade?.gradeNumber ?? '').toString(),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
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
