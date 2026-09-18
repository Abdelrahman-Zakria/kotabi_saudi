import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import '../pdf_reader/pdf_reader_screen.dart';

class HululiBookDetailsScreen extends StatelessWidget {
  final BookModel book;

  const HululiBookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final stageColor = AppColors.primary;
    final gradeDisplayName =
        GradeModel.getById(book.grade)?.displayName ?? book.grade;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تفاصيل الملف',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
        backgroundColor: stageColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
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
                Text(
                  book.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoRow(label: 'المادة', value: book.subject),
                _InfoRow(label: 'الصف', value: gradeDisplayName),
                _InfoRow(label: 'المرحلة', value: book.stage),
                _InfoRow(label: 'الفصل', value: book.semester),
                _InfoRow(label: 'النوع', value: _contentTypeLabel(book)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _openPdfReader(context, book),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text(
              'فتح PDF داخل القارئ',
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: stageColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if ((book.pageUrl ?? '').trim().isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => _launchExternal(book.pageUrl!),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text(
                'فتح صفحة المصدر',
                style:
                    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: stageColor,
                side: BorderSide(color: stageColor.withOpacity(0.55)),
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
      MaterialPageRoute(builder: (_) => PdfReaderScreen(book: book)),
    );
  }

  String _contentTypeLabel(BookModel book) {
    switch (book.contentType) {
      case 'solution':
        return 'حلول';
      case 'worksheet':
        return 'أوراق عمل';
      case 'exam':
        return 'اختبارات';
      case 'summary':
        return 'ملخصات';
      case 'distribution':
        return 'توزيع';
      case 'preparation':
        return 'تحضير';
      case 'presentation':
        return 'عرض';
      case 'content':
        return 'محتوى';
      case 'book':
        return 'كتاب';
      default:
        return book.contentType;
    }
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
