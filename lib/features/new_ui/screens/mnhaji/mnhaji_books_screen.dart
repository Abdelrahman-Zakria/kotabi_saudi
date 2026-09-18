import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import 'package:kotabi_saudi/core/services/mnhaji_source_catalog_service.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_card.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_cover_image.dart';
import '../pdf_reader/pdf_reader_screen.dart';
import '../browse/subject_books_screen.dart';

class MnhajiBooksScreen extends StatefulWidget {
  final GradeModel grade;

  const MnhajiBooksScreen({super.key, required this.grade});

  @override
  State<MnhajiBooksScreen> createState() => _MnhajiBooksScreenState();
}

class _MnhajiBooksScreenState extends State<MnhajiBooksScreen> {
  final MnhajiSourceCatalogService _service =
      MnhajiSourceCatalogService.manhajiBooks;
  late final Future<List<BookModel>> _booksFuture =
      _service.fetchBooksForGrade(widget.grade.id);

  String _query = '';
  String _selectedSemester = 'الفصل الدراسي الأول';

  @override
  Widget build(BuildContext context) {
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
                widget.grade.displayName,
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
                  hintText: 'ابحث عن كتاب أو مادة...',
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
          FutureBuilder<List<BookModel>>(
            future: _booksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              final books = snapshot.data ?? const <BookModel>[];
              
              final queryFiltered = _applyQuery(books, _query);
              // Force use of 1st and 2nd semesters only
              final filtered = queryFiltered.where((book) {
                if (_selectedSemester.contains('الأول')) return book.semester.contains('الأول');
                if (_selectedSemester.contains('الثاني')) return book.semester.contains('الثاني');
                return false;
              }).toList();

              // Extract unique subjects from filtered books
              final subjects = filtered
                  .map((book) => book.subject.trim())
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()..sort();

              if (filtered.isEmpty) {
                return const SliverFillRemaining(
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
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 14),
                      Center(
                        child: Container(
                          width: double.infinity,
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
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text(
                          'المواد الدراسية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: subjects.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.82,
                        ),
                        itemBuilder: (context, index) {
                          final subjectName = subjects[index];
                          final subjectBooks = filtered.where((b) => b.subject == subjectName).toList();
                          final representativeBook = subjectBooks.firstWhere(
                            (b) => b.contentType == 'book',
                            orElse: () => subjectBooks.first,
                          );

                          return _SubjectGridCard(
                            subjectName: subjectName,
                            representativeBook: representativeBook,
                            bookCount: subjectBooks.length,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubjectBooksScreen(
                                    grade: widget.grade,
                                    subject: subjectName,
                                    books: subjectBooks,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterTab(String semester) {
    final isSelected = _selectedSemester == semester;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSemester = semester),
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

  Map<String, List<BookModel>> _groupBySubject(List<BookModel> books) {
    final map = <String, List<BookModel>>{};
    for (final book in books) {
      final key =
          book.subject.trim().isEmpty ? 'مواد أخرى' : book.subject.trim();
      (map[key] ??= <BookModel>[]).add(book);
    }
    return map;
  }

  List<BookModel> _applyQuery(List<BookModel> books, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return books;

    final normalized = _normalize(trimmed);
    return books.where((book) {
      return _normalize(book.title).contains(normalized) ||
          _normalize(book.subject).contains(normalized) ||
          _normalize(book.semester).contains(normalized) ||
          _normalize(book.contentType).contains(normalized);
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

class _SubjectGridCard extends StatelessWidget {
  final String subjectName;
  final BookModel representativeBook;
  final int bookCount;
  final VoidCallback onTap;

  const _SubjectGridCard({
    required this.subjectName,
    required this.representativeBook,
    required this.bookCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BookCoverImage(
                      book: representativeBook,
                      fallback: Icon(
                        _getSubjectIcon(subjectName),
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subjectName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$bookCount عنصر',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('رياضيات')) return Icons.calculate_rounded;
    if (s.contains('علوم')) return Icons.science_rounded;
    if (s.contains('لغتي') || s.contains('عربي')) return Icons.translate_rounded;
    if (s.contains('انجليزي') || s.contains('إنجليزي')) return Icons.language_rounded;
    if (s.contains('إسلامي') || s.contains('توحيد') || s.contains('فقه') || s.contains('حديث') || s.contains('تفسير') || s.contains('قرآن')) return Icons.mosque_rounded;
    if (s.contains('اجتماعيات') || s.contains('تاريخ') || s.contains('جغرافيا')) return Icons.public_rounded;
    if (s.contains('فنية')) return Icons.palette_rounded;
    if (s.contains('بدنية')) return Icons.sports_soccer_rounded;
    if (s.contains('حاسب') || s.contains('رقمية')) return Icons.computer_rounded;
    return Icons.book_rounded;
  }
}
