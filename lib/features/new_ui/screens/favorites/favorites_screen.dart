import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/new_ui/strings.dart';
import 'package:kotabi_saudi/core/providers/favorites_provider.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/book_card.dart';
import 'package:kotabi_saudi/features/new_ui/widgets/loading_widget.dart' as custom_widgets;
import '../pdf_reader/pdf_reader_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.favorites),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, provider, _) {
              if (provider.favorites.isEmpty) return const SizedBox();
              return TextButton.icon(
                onPressed: () => _showClearDialog(context, provider),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'مسح الكل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, _) {
          final favorites = provider.favorites;

          if (favorites.isEmpty) {
            return const custom_widgets.EmptyWidget(
              title: AppStrings.favoritesEmpty,
              description: AppStrings.favoritesEmptyDesc,
              icon: Icons.favorite_border_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final book = favorites[index];
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

  void _showClearDialog(BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'مسح المفضلة',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل أنت متأكد من مسح جميع الكتب المفضلة؟',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    provider.clearFavorites();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE05C6B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'مسح',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
