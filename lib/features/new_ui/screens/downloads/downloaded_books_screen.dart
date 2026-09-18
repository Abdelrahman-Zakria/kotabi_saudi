import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/providers/reader_library_provider.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/loading_widget.dart' as custom_widgets;
import '../pdf_reader/pdf_reader_screen.dart';

class DownloadedBooksScreen extends StatelessWidget {
  const DownloadedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الكتب المحمّلة'),
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ReaderLibraryProvider>(
        builder: (context, provider, _) {
          final downloadedBooks = provider.downloadedBooks;

          if (downloadedBooks.isEmpty) {
            return const custom_widgets.EmptyWidget(
              title: 'لا توجد كتب محمّلة',
              description:
                  'نزّل أي كتاب من داخل القارئ وسيظهر هنا للوصول السريع بدون انتظار.',
              icon: Icons.download_done_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: downloadedBooks.length,
            itemBuilder: (context, index) {
              final entry = downloadedBooks[index];
              final lastPage = provider.getLastPage(entry.book.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.download_done_rounded,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  title: Text(
                    entry.book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${entry.book.subject}  •  آخر صفحة: $lastPage  •  ${_formatFileSize(entry.fileSizeBytes)}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.error,
                    onPressed: () => _confirmDelete(context, entry.book.id),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfReaderScreen(book: entry.book),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف الكتاب المحمّل',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'سيتم حذف النسخة المحفوظة محليًا مع بقاء الكتاب متاحًا عبر الإنترنت.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'حذف',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ReaderLibraryProvider>().removeDownloadedBook(bookId);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return 'غير معروف';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}
