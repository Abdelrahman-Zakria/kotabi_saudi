import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/kotbi_1447_models.dart';
import 'kotbi_1447_book_details_screen.dart';

class Kotbi1447SubjectDetailsScreen extends StatelessWidget {
  final Kotbi1447Grade grade;
  final Kotbi1447SubjectGroup subjectGroup;

  const Kotbi1447SubjectDetailsScreen({
    super.key,
    required this.grade,
    required this.subjectGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(subjectGroup.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          _SubjectHeader(subjectGroup: subjectGroup),
          const SizedBox(height: 14),
          ...subjectGroup.terms.map(
            (termSubject) => _TermResourcesSection(
              grade: grade,
              termSubject: termSubject,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  final Kotbi1447SubjectGroup subjectGroup;

  const _SubjectHeader({required this.subjectGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                subjectGroup.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primary.withOpacity(0.12),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectGroup.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subjectGroup.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subjectGroup.description,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                _CountPill(count: subjectGroup.resourceCount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermResourcesSection extends StatelessWidget {
  final Kotbi1447Grade grade;
  final Kotbi1447SubjectTerm termSubject;

  const _TermResourcesSection({
    required this.grade,
    required this.termSubject,
  });

  @override
  Widget build(BuildContext context) {
    final resources = termSubject.subject.resources;
    if (resources.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            collapsedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            title: Text(
              termSubject.term.name,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            children: resources.map((resource) {
              return _ResourceTile(
                resource: resource,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Kotbi1447BookDetailsScreen(
                      grade: grade,
                      term: termSubject.term,
                      subject: termSubject.subject,
                      resource: resource,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final Kotbi1447Resource resource;
  final VoidCallback onTap;

  const _ResourceTile({
    required this.resource,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    resource.imageUrl,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 54,
                      height: 54,
                      color: AppColors.primary.withOpacity(0.12),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.shortTitle.trim().isEmpty
                            ? resource.title
                            : resource.shortTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource.type.trim().isEmpty ? 'ملف' : resource.type,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;

  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$count ملف',
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
