import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/models/kotbi_1447_models.dart';
import '../pdf_reader/pdf_reader_screen.dart';

class Kotbi1447BookDetailsScreen extends StatelessWidget {
  final Kotbi1447Grade grade;
  final Kotbi1447Term term;
  final Kotbi1447Subject subject;
  final Kotbi1447Resource resource;

  const Kotbi1447BookDetailsScreen({
    super.key,
    required this.grade,
    required this.term,
    required this.subject,
    required this.resource,
  });

  @override
  Widget build(BuildContext context) {
    final book = resource.toBookModel(
      grade: grade,
      term: term,
      subject: subject,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تفاصيل الملف',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      resource.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.12),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: AppColors.primary,
                          size: 52,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (resource.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          resource.description,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _InfoRow(label: 'المادة', value: subject.name),
                      _InfoRow(
                        label: 'الصف',
                        value: grade.appGrade?.displayName ?? grade.name,
                      ),
                      _InfoRow(label: 'المرحلة', value: grade.stage),
                      _InfoRow(label: 'الفصل', value: term.name),
                      _InfoRow(label: 'النوع', value: resource.type),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: resource.pdfUrl.trim().isEmpty
                ? null
                : () => _openPdfReader(context, book),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text(
              'فتح PDF داخل القارئ',
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPdfReader(BuildContext context, BookModel book) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfReaderScreen(book: book),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cleaned = value.trim().isEmpty ? '-' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              cleaned,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
