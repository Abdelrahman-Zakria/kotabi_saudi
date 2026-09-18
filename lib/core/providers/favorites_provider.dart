import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();
  bool _initialized = false;

  List<BookModel> get favorites => _favoritesService.favorites;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    await _favoritesService.initialize();
    _initialized = true;
    notifyListeners();
  }

  bool isFavorite(String bookId) => _favoritesService.isFavorite(bookId);

  Future<void> toggleFavorite(BookModel book) async {
    await _favoritesService.toggleFavorite(book);
    notifyListeners();
  }

  Future<void> addToFavorites(BookModel book) async {
    await _favoritesService.addToFavorites(book);
    notifyListeners();
  }

  Future<void> removeFromFavorites(String bookId) async {
    await _favoritesService.removeFromFavorites(bookId);
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    await _favoritesService.clearFavorites();
    notifyListeners();
  }
}
