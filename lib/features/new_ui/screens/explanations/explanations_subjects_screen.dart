import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/explanations_catalog_models.dart';
import 'explanations_chapters_screen.dart';

class ExplanationsSubjectsScreen extends StatelessWidget {
  final ExplanationSemester semester;
  final ExplanationGrade grade;

  const ExplanationsSubjectsScreen({
    super.key,
    required this.semester,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = grade.subjects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          grade.name,
          style:
              const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return _SubjectCard(
            title: subject.name,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExplanationsChaptersScreen(
                  semester: semester,
                  grade: grade,
                  subject: subject,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SubjectCard({required this.title, required this.onTap});

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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                ),
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
