import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/new_ui/strings.dart';
import 'package:kotabi_saudi/core/providers/books_provider.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_card.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/loading_widget.dart' as custom_widgets;
import '../pdf_reader/pdf_reader_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      final initialQuery = widget.initialQuery?.trim() ?? '';
      if (initialQuery.isNotEmpty) {
        _controller.text = initialQuery;
        context.read<BooksProvider>().searchBooks(initialQuery);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textDirection: TextDirection.rtl,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              hintStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () {
                        _controller.clear();
                        context.read<BooksProvider>().clearSearch();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
              context.read<BooksProvider>().searchBooks(value);
            },
          ),
        ),
      ),
      body: Consumer<BooksProvider>(
        builder: (context, provider, _) {
          if (provider.searchQuery.isEmpty) {
            return Center(child: _buildEmptySearch());
          }

          if (provider.searchState == LoadingState.loading) {
            return const custom_widgets.LoadingListTiles(count: 4);
          }

          if (provider.searchResults.isEmpty) {
            return Center(
              child: custom_widgets.EmptyWidget(
                title: 'لا توجد نتائج',
                description: 'لم نجد كتباً تطابق "${provider.searchQuery}"',
                icon: Icons.search_off_rounded,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final book = provider.searchResults[index];
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
          );
        },
      ),
    );
  }

  Widget _buildEmptySearch() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ابحث عن كتابك',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'يمكنك البحث باسم الكتاب أو المادة الدراسية أو الصف لسرعة الوصول',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 8, bottom: 12),
              child: Text(
                'اقتراحات البحث:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              'رياضيات',
              'لغتي',
              'علوم',
              'انجليزي',
              'اجتماعيات',
              'تربية إسلامية',
            ].map((suggestion) {
              return GestureDetector(
                onTap: () {
                  _controller.text = suggestion;
                  context.read<BooksProvider>().searchBooks(suggestion);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
