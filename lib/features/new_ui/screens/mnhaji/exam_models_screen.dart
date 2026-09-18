import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import 'package:kotabi_saudi/core/services/mnhaji_source_catalog_service.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_card.dart';
import '../pdf_reader/pdf_reader_screen.dart';

class ExamModelsScreen extends StatefulWidget {
  final GradeModel grade;

  const ExamModelsScreen({super.key, required this.grade});

  @override
  State<ExamModelsScreen> createState() => _ExamModelsScreenState();
}

class _ExamModelsScreenState extends State<ExamModelsScreen> {
  final MnhajiSourceCatalogService _service =
      MnhajiSourceCatalogService.examModels;
  late final Future<List<BookModel>> _booksFuture =
      _service.fetchBooksForGrade(widget.grade.id);

  String _query = '';
  String _selectedSemester = 'الكل';

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
                    Icons.quiz_rounded,
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
                  hintText: 'ابحث عن اختبار أو مادة...',
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
              final availableSemesters = _buildSemesters(books);
              _syncSemesterSelection(availableSemesters);

              final queryFiltered = _applyQuery(books, _query);
              final filtered = _applySemester(queryFiltered, _selectedSemester);

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

              final grouped = _groupBySubject(filtered);
              final subjectKeys = grouped.keys.toList()
                ..sort((a, b) => a.compareTo(b));

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _SemesterStrip(
                        semesters: availableSemesters,
                        selectedSemester: _selectedSemester,
                        onSelected: (value) =>
                            setState(() => _selectedSemester = value),
                      ),
                      const SizedBox(height: 12),
                      ...subjectKeys.map(
                        (subject) => _SubjectSection(
                          subject: subject,
                          books: grouped[subject] ?? const [],
                          onOpen: (book) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfReaderScreen(book: book),
                            ),
                          ),
                          initiallyExpanded: _query.trim().isNotEmpty &&
                              (grouped[subject]?.length ?? 0) <= 12,
                        ),
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

  void _syncSemesterSelection(List<String> semesters) {
    if (_selectedSemester == 'الكل') return;
    if (semesters.contains(_selectedSemester)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _selectedSemester = 'الكل');
    });
  }

  List<String> _buildSemesters(List<BookModel> books) {
    final set = books
        .map((book) => book.semester.trim())
        .where((value) => value.isNotEmpty)
        .toSet();

    final semesters = set.toList()
      ..sort((a, b) => _semesterPriority(a).compareTo(_semesterPriority(b)));

    return ['الكل', ...semesters];
  }

  List<BookModel> _applySemester(List<BookModel> books, String semester) {
    if (semester == 'الكل') return books;
    final target = _normalize(semester);
    return books.where((book) => _normalize(book.semester) == target).toList();
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

  int _semesterPriority(String semester) {
    final normalized = _normalize(semester);
    if (normalized == _normalize('الفصل الأول')) return 0;
    if (normalized == _normalize('الفصل الثاني')) return 1;
    if (normalized == _normalize('الفصل الثالث')) return 2;
    return 99;
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

class _SemesterStrip extends StatelessWidget {
  final List<String> semesters;
  final String selectedSemester;
  final ValueChanged<String> onSelected;

  const _SemesterStrip({
    required this.semesters,
    required this.selectedSemester,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (semesters.length <= 2) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر الفصل',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: semesters.map((semester) {
              final isSelected = selectedSemester == semester;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => onSelected(semester),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border.withOpacity(0.9),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      semester,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w700,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SubjectSection extends StatelessWidget {
  final String subject;
  final List<BookModel> books;
  final ValueChanged<BookModel> onOpen;
  final bool initiallyExpanded;

  const _SubjectSection({
    required this.subject,
    required this.books,
    required this.onOpen,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            initiallyExpanded: initiallyExpanded,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            collapsedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            title: Text(
              subject,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: null,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.74,
                ),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return BookCard(
                    book: book,
                    onTap: () => onOpen(book),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
