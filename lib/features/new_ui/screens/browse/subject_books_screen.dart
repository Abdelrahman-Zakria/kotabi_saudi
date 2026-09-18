import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_card.dart';
import '../pdf_reader/pdf_reader_screen.dart';

class SubjectBooksScreen extends StatefulWidget {
  final GradeModel grade;
  final String subject;
  final List<BookModel> books;

  const SubjectBooksScreen({
    super.key,
    required this.grade,
    required this.subject,
    required this.books,
  });

  @override
  State<SubjectBooksScreen> createState() => _SubjectBooksScreenState();
}

class _SubjectBooksScreenState extends State<SubjectBooksScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final sortedBooks = [...widget.books]..sort(_compareBooks);
    final counts = <String, int>{};
    for (final book in sortedBooks) {
      counts.update(book.contentType, (value) => value + 1, ifAbsent: () => 1);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: widget.grade.color,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                widget.subject,
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
                      widget.grade.color,
                      widget.grade.color.withOpacity(0.8),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.grade.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.grade.displayName,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.grade.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: counts.entries
                          .where((entry) => entry.value > 0)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: widget.grade.color.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  '${_contentTypeLabel(entry.key)} ${entry.value}',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: widget.grade.color,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${sortedBooks.length} عنصر متاح',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.grid_view_rounded,
                              color: _isGridView
                                  ? widget.grade.color
                                  : AppColors.textLight,
                            ),
                            onPressed: () => setState(() => _isGridView = true),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.view_list_rounded,
                              color: !_isGridView
                                  ? widget.grade.color
                                  : AppColors.textLight,
                            ),
                            onPressed: () =>
                                setState(() => _isGridView = false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isGridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = sortedBooks[index];
                    return BookCard(
                      book: book,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfReaderScreen(book: book),
                        ),
                      ),
                    );
                  },
                  childCount: sortedBooks.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = sortedBooks[index];
                    return BookListTile(
                      book: book,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfReaderScreen(book: book),
                        ),
                      ),
                    );
                  },
                  childCount: sortedBooks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _compareBooks(BookModel a, BookModel b) {
    final typeCompare = _contentPriority(a.contentType)
        .compareTo(_contentPriority(b.contentType));
    if (typeCompare != 0) return typeCompare;
    return a.title.compareTo(b.title);
  }

  int _contentPriority(String type) {
    const order = {
      'book': 0,
      'solution': 1,
      'exam': 2,
      'summary': 3,
      'worksheet': 4,
      'distribution': 5,
      'preparation': 6,
      'presentation': 7,
      'content': 8,
    };
    return order[type] ?? 99;
  }

  String _contentTypeLabel(String type) {
    switch (type) {
      case 'solution':
        return 'حلول';
      case 'exam':
        return 'اختبارات';
      case 'worksheet':
        return 'أوراق عمل';
      case 'summary':
        return 'ملخصات';
      case 'distribution':
        return 'توزيع';
      case 'preparation':
        return 'تحضير';
      case 'presentation':
        return 'عروض';
      case 'content':
        return 'محتوى';
      case 'book':
      default:
        return 'كتب';
    }
  }

  String _semesterCount(List<BookModel> books) {
    final count = books.map((book) => book.semester).toSet().length;
    return '$count';
  }
}
