import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/strings.dart';
import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/explanations_catalog_models.dart';
import 'package:kotabi_saudi/core/services/explanations_catalog_service.dart';
import 'explanations_subjects_screen.dart';

class ExplanationsSemestersScreen extends StatefulWidget {
  const ExplanationsSemestersScreen({super.key});

  @override
  State<ExplanationsSemestersScreen> createState() =>
      _ExplanationsSemestersScreenState();
}

class _ExplanationsSemestersScreenState
    extends State<ExplanationsSemestersScreen> {
  final ExplanationsCatalogService _service =
      ExplanationsCatalogService.instance;
  late final Future<List<ExplanationSemester>> _future =
      _service.fetchSemesters();

  String _selectedSemesterName = 'الفصل الدراسي الأول';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.bookExplanations,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ExplanationSemester>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final allSemesters = snapshot.data ?? const [];
          if (allSemesters.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد شروحات حالياً',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          // Filter for the selected semester
          final currentSemester = allSemesters.firstWhere(
            (s) => s.name.contains(_selectedSemesterName.replaceAll('الفصل الدراسي ', '')),
            orElse: () => allSemesters.first,
          );

          final grades = currentSemester.grades;

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 54,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        _buildSemesterTab('الفصل الدراسي الأول'),
                        const SizedBox(width: 5),
                        _buildSemesterTab('الفصل الدراسي الثاني'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: grades.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final grade = grades[index];
                    return _GradeCard(
                      title: grade.name,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExplanationsSubjectsScreen(
                            semester: currentSemester,
                            grade: grade,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSemesterTab(String semester) {
    final isSelected = _selectedSemesterName == semester;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSemesterName = semester),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Text(
            semester,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _GradeCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
