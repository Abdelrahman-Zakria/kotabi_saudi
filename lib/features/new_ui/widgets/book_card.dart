import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/new_ui/helpers.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/providers/favorites_provider.dart';
import 'book_cover_image.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = favoritesProvider.isFavorite(book.id);
    final subjectIcon = AppHelpers.getSubjectIcon(book.subject);
    final contentLabel = _contentTypeLabel(book.contentType);
    final stageColor = AppHelpers.getStageColor(book.stage);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Book Cover / Header
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        stageColor,
                        stageColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _BookThumbnail(
                          book: book,
                          subjectIcon: subjectIcon,
                          backgroundColor: stageColor,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.28),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Favorite Button
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () {
                            context
                                .read<FavoritesProvider>()
                                .toggleFavorite(book);
                            AppHelpers.showSnackBar(
                              context,
                              isFav
                                  ? 'تمت الإزالة من المفضلة'
                                  : 'تمت الإضافة للمفضلة',
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                              color: isFav ? Colors.red.shade300 : Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Content Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            contentLabel,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Book Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppHelpers.getStageColor(book.stage)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            book.subject,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppHelpers.getStageColor(book.stage),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Book Title
                        Expanded(
                          child: Text(
                            book.title,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Semester
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                book.semester,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _contentTypeLabel(String type) {
    switch (type) {
      case 'solution':
        return 'حل';
      case 'exam':
        return 'اختبار';
      case 'worksheet':
        return 'ورقة';
      case 'summary':
        return 'ملخص';
      case 'distribution':
        return 'توزيع';
      case 'preparation':
        return 'تحضير';
      case 'presentation':
        return 'عرض';
      case 'content':
        return 'محتوى';
      case 'book':
      default:
        return 'كتاب';
    }
  }
}

class BookListTile extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;

  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = favoritesProvider.isFavorite(book.id);
    final subjectIcon = AppHelpers.getSubjectIcon(book.subject);
    final stageColor = AppHelpers.getStageColor(book.stage);
    final contentLabel = _contentTypeLabel(book.contentType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Subject Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: _BookThumbnail(
                      book: book,
                      subjectIcon: subjectIcon,
                      backgroundColor: stageColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Book Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: stageColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$contentLabel • ${book.subject}',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: stageColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            book.semester,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Favorite + Open
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<FavoritesProvider>().toggleFavorite(book);
                      },
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 22,
                        color:
                            isFav ? Colors.red.shade400 : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _contentTypeLabel(String type) {
    switch (type) {
      case 'solution':
        return 'حل';
      case 'exam':
        return 'اختبار';
      case 'worksheet':
        return 'ورقة';
      case 'summary':
        return 'ملخص';
      case 'distribution':
        return 'توزيع';
      case 'preparation':
        return 'تحضير';
      case 'presentation':
        return 'عرض';
      case 'content':
        return 'محتوى';
      case 'book':
      default:
        return 'كتاب';
    }
  }
}

class _BookThumbnail extends StatelessWidget {
  final BookModel book;
  final IconData subjectIcon;
  final Color backgroundColor;
  final BorderRadius? borderRadius;

  const _BookThumbnail({
    required this.book,
    required this.subjectIcon,
    required this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return BookCoverImage(
      book: book,
      fallback: _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.16),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            subjectIcon,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
