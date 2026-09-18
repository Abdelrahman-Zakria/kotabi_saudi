import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../models/grade_model.dart';
import '../services/scraping_service.dart';

enum LoadingState { idle, loading, success, error }

class BooksProvider extends ChangeNotifier {
  final ScrapingService _scrapingService = ScrapingService();

  final Map<String, List<BookModel>> _booksByGrade = {};
  final Map<String, LoadingState> _loadingStates = {};
  final Map<String, String> _errorMessages = {};

  String _searchQuery = '';
  List<BookModel> _searchResults = [];
  LoadingState _searchState = LoadingState.idle;

  // Getters
  List<BookModel> getBooksForGrade(String gradeId) =>
      _booksByGrade[gradeId] ?? [];

  LoadingState getLoadingState(String gradeId) =>
      _loadingStates[gradeId] ?? LoadingState.idle;

  String? getError(String gradeId) => _errorMessages[gradeId];

  String get searchQuery => _searchQuery;
  List<BookModel> get searchResults => _searchResults;
  LoadingState get searchState => _searchState;

  Future<void> fetchBooksForGrade(GradeModel grade) async {
    final gradeId = grade.id;

    if (_loadingStates[gradeId] == LoadingState.loading) return;
    if (_booksByGrade[gradeId] != null && _booksByGrade[gradeId]!.isNotEmpty) return;

    _loadingStates[gradeId] = LoadingState.loading;
    _errorMessages.remove(gradeId);
    notifyListeners();

    try {
      final books = await _scrapingService.fetchBooksForGrade(
        gradeId: gradeId,
        wajibiPath: grade.wajibiPath ?? '/$gradeId',
      );

      if (books.isEmpty) {
        _booksByGrade[gradeId] = const [];
        _loadingStates[gradeId] = LoadingState.success;
        _errorMessages[gradeId] = gradeId.startsWith('kg')
            ? 'مصدر الكتب الحالي لا يوفّر كتب رياض الأطفال بشكل ثابت حالياً.'
            : 'لم نتمكن من العثور على كتب لهذا الصف حالياً. قد تكون النتيجة فارغة مؤقتاً، حاول مرة أخرى.';
      } else {
        _booksByGrade[gradeId] = books;
        _loadingStates[gradeId] = LoadingState.success;
        _errorMessages.remove(gradeId);
      }
    } catch (e) {
      _booksByGrade.remove(gradeId);
      _loadingStates[gradeId] = LoadingState.error;
      _errorMessages[gradeId] = e.toString();
    }

    notifyListeners();
  }

  Future<void> refreshBooksForGrade(GradeModel grade) async {
    _booksByGrade.remove(grade.id);
    await fetchBooksForGrade(grade);
  }

  void updateBookFavoriteStatus(String bookId, bool isFavorite) {
    for (final gradeId in _booksByGrade.keys) {
      final books = _booksByGrade[gradeId]!;
      final index = books.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        books[index] = books[index].copyWith(isFavorite: isFavorite);
      }
    }
    // Also update search results
    final searchIndex = _searchResults.indexWhere((b) => b.id == bookId);
    if (searchIndex != -1) {
      _searchResults[searchIndex] = _searchResults[searchIndex].copyWith(isFavorite: isFavorite);
    }
    notifyListeners();
  }

  Future<void> searchBooks(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchState = LoadingState.idle;
      notifyListeners();
      return;
    }

    _searchState = LoadingState.loading;
    notifyListeners();

    try {
      // Search in cached books
      final results = await _scrapingService.searchBooks(query);

      // Also search in locally loaded books
      final localResults = <BookModel>[];
      for (final books in _booksByGrade.values) {
        for (final book in books) {
          if ((book.title.contains(query) || book.subject.contains(query)) &&
              !results.any((r) => r.id == book.id)) {
            localResults.add(book);
          }
        }
      }

      _searchResults = [...results, ...localResults];
      _searchState = LoadingState.success;
    } catch (e) {
      _searchState = LoadingState.error;
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _searchState = LoadingState.idle;
    notifyListeners();
  }
}
