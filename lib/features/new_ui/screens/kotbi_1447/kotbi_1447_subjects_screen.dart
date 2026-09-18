import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/kotbi_1447_models.dart';
import 'kotbi_1447_subject_details_screen.dart';

class Kotbi1447SubjectsScreen extends StatefulWidget {
  final Kotbi1447Grade grade;

  const Kotbi1447SubjectsScreen({super.key, required this.grade});

  @override
  State<Kotbi1447SubjectsScreen> createState() =>
      _Kotbi1447SubjectsScreenState();
}

class _Kotbi1447SubjectsScreenState extends State<Kotbi1447SubjectsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allSubjects = widget.grade.subjectGroups;
    final subjects = _applyQuery(allSubjects);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.grade.appGrade?.displayName ?? widget.grade.name,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 70,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مادة...',
                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ),
          if (subjects.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'لا توجد نتائج',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              sliver: SliverGrid.builder(
                itemCount: subjects.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.76,
                ),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _SubjectCard(
                    subject: subject,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Kotbi1447SubjectDetailsScreen(
                          grade: widget.grade,
                          subjectGroup: subject,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Kotbi1447SubjectGroup> _applyQuery(
    List<Kotbi1447SubjectGroup> subjects,
  ) {
    final normalized = _normalize(_query);
    if (normalized.isEmpty) return subjects;
    return subjects.where((subject) {
      return _normalize(subject.name).contains(normalized) ||
          _normalize(subject.description).contains(normalized) ||
          _normalize(subject.key).contains(normalized);
    }).toList();
  }

  String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }
}

class _SubjectCard extends StatelessWidget {
  final Kotbi1447SubjectGroup subject;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
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
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    subject.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primary.withOpacity(0.12),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primary,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      subject.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.resourceCount} ملف',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
