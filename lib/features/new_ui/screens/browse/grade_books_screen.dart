import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/models/grade_model.dart';
import 'package:kotabi_saudi/core/providers/books_provider.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_card.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_cover_image.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/loading_widget.dart' as custom_widgets;
import '../pdf_reader/pdf_reader_screen.dart';
import 'subject_books_screen.dart';

class GradeBooksScreen extends StatefulWidget {
  final GradeModel grade;

  const GradeBooksScreen({super.key, required this.grade});

  @override
  State<GradeBooksScreen> createState() => _GradeBooksScreenState();
}

class _GradeBooksScreenState extends State<GradeBooksScreen> {
  String _selectedSemester = 'الفصل الدراسي الأول';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().fetchBooksForGrade(widget.grade);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: widget.grade.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.grade.displayName,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.grade.color,
                      widget.grade.color.withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          // Header and Filters
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Professional Semester Toggle (Two Tabs)
                  Center(
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
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: widget.grade.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'المواد الدراسية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      'تصفح محتوى المناهج لـ ${widget.grade.displayName}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Subjects List Content
          Consumer<BooksProvider>(
            builder: (context, provider, _) {
              final state = provider.getLoadingState(widget.grade.id);
              final allBooks = provider.getBooksForGrade(widget.grade.id);
              
              // Filter books by selected semester first
              final filteredBySemester = allBooks.where((book) {
                return _selectedSemester == 'الكل' || 
                       book.semester == _selectedSemester ||
                       _semesterCoversSelection(book.semester, _selectedSemester);
              }).toList();

              // Extract unique subjects from filtered books
              final subjects = filteredBySemester
                  .map((book) => book.subject.trim())
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()..sort();

              if (state == LoadingState.loading) {
                return const SliverFillRemaining(
                  child: custom_widgets.LoadingListTiles(),
                );
              }

              if (state == LoadingState.error) {
                return SliverFillRemaining(
                  child: custom_widgets.ErrorWidget(
                    message: provider.getError(widget.grade.id) ?? 'تعذر تحميل المواد',
                    onRetry: () => provider.refreshBooksForGrade(widget.grade),
                  ),
                );
              }

              if (subjects.isEmpty) {
                return SliverFillRemaining(
                  child: custom_widgets.EmptyWidget(
                    title: 'لا توجد مواد',
                    description: 'لم يتم العثور على مواد دراسية لهذا الفصل حالياً',
                    icon: Icons.subject_rounded,
                    actionLabel: 'إعادة المحاولة',
                    onAction: () => provider.refreshBooksForGrade(widget.grade),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subjectName = subjects[index];
                      final subjectBooks = filteredBySemester.where((b) => b.subject == subjectName).toList();
                      
                      final representativeBook = subjectBooks.firstWhere(
                        (b) => b.contentType == 'book',
                        orElse: () => subjectBooks.first,
                      );
                      
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
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
                                      color: widget.grade.color.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: BookCoverImage(
                                        book: representativeBook,
                                        fallback: Icon(
                                          _getSubjectIcon(subjectName),
                                          color: widget.grade.color,
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
                                    color: widget.grade.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${subjectBooks.length} عنصر',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: widget.grade.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: subjects.length,
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
              color: isSelected ? widget.grade.color : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  bool _semesterCoversSelection(String bookSemester, String selectedSemester) {
    // Normalize comparison: handle both "الفصل الأول" and "الفصل الدراسي الأول"
    final b = bookSemester.trim();
    final s = selectedSemester.trim();
    
    if (s.contains('الأول')) return b.contains('الأول');
    if (s.contains('الثاني')) return b.contains('الثاني');
    
    return false;
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
