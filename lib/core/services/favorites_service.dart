import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';
import '../constants/app_constants.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  List<BookModel> _favorites = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _loadFavorites();
    _initialized = true;
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(AppConstants.keyFavoriteBooks) ?? [];
      _favorites = favoritesJson
          .map((json) => BookModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      _favorites = [];
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites
          .map((book) => jsonEncode(book.toJson()))
          .toList();
      await prefs.setStringList(AppConstants.keyFavoriteBooks, favoritesJson);
    } catch (e) {
      // Handle error silently
    }
  }

  List<BookModel> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String bookId) {
    return _favorites.any((book) => book.id == bookId);
  }

  Future<void> addToFavorites(BookModel book) async {
    if (!isFavorite(book.id)) {
      _favorites.add(book.copyWith(isFavorite: true));
      await _saveFavorites();
    }
  }

  Future<void> removeFromFavorites(String bookId) async {
    _favorites.removeWhere((book) => book.id == bookId);
    await _saveFavorites();
  }

  Future<void> toggleFavorite(BookModel book) async {
    if (isFavorite(book.id)) {
      await removeFromFavorites(book.id);
    } else {
      await addToFavorites(book);
    }
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveFavorites();
  }
}
