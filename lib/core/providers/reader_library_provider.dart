import 'package:flutter/foundation.dart';

import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/services/reader_library_service.dart';

class ReaderLibraryProvider extends ChangeNotifier {
  final ReaderLibraryService _readerLibraryService = ReaderLibraryService();

  bool _initialized = false;
  final Set<String> _downloadingIds = {};
  final Set<String> _persistingIds = {};

  bool get isInitialized => _initialized;
  List<DownloadedBookEntry> get downloadedBooks =>
      _readerLibraryService.downloadedBooks;
  List<RecentBookEntry> get recentBooks => _readerLibraryService.recentBooks;
  List<WeeklyPlanItem> get weeklyPlan => _readerLibraryService.weeklyPlan;
  int get totalBookmarksCount => _readerLibraryService.totalBookmarksCount;
  int get totalNotesCount => _readerLibraryService.totalNotesCount;
  int get booksWithProgressCount => _readerLibraryService.booksWithProgressCount;

  Future<void> initialize() async {
    if (_initialized) return;
    await _readerLibraryService.initialize();
    _initialized = true;
    notifyListeners();
  }

  bool isDownloaded(String bookId) =>
      _readerLibraryService.isDownloaded(bookId);

  bool isDownloading(String bookId) => _downloadingIds.contains(bookId);

  bool isPersisting(String bookId) => _persistingIds.contains(bookId);

  DownloadedBookEntry? getDownloadedBook(String bookId) {
    return _readerLibraryService.getDownloadedBook(bookId);
  }

  int getLastPage(String bookId) => _readerLibraryService.getLastPage(bookId);

  String getScrollDirection(String bookId) {
    return _readerLibraryService.getScrollDirection(bookId);
  }

  List<int> getBookmarks(String bookId) {
    return _readerLibraryService.getBookmarks(bookId);
  }

  List<BookPageNote> getNotes(String bookId) {
    return _readerLibraryService.getNotes(bookId);
  }

  BookPageNote? getNoteForPage(String bookId, int page) {
    return _readerLibraryService.getNoteForPage(bookId, page);
  }

  Future<void> downloadBook(
    BookModel book,
    Uint8List pdfBytes, {
    String? sourceUrl,
  }) async {
    _downloadingIds.add(book.id);
    notifyListeners();

    try {
      await _readerLibraryService.saveDownloadedBook(
        book,
        pdfBytes,
        sourceUrl: sourceUrl,
      );
    } finally {
      _downloadingIds.remove(book.id);
      notifyListeners();
    }
  }

  Future<void> persistDocumentIfDownloaded(
    String bookId,
    Uint8List pdfBytes,
  ) async {
    if (!isDownloaded(bookId)) return;

    _persistingIds.add(bookId);
    notifyListeners();

    try {
      await _readerLibraryService.updateDownloadedDocument(bookId, pdfBytes);
    } finally {
      _persistingIds.remove(bookId);
      notifyListeners();
    }
  }

  Future<void> saveDocumentLocally(
    BookModel book,
    Uint8List pdfBytes, {
    String? sourceUrl,
  }) async {
    _persistingIds.add(book.id);
    notifyListeners();

    try {
      await _readerLibraryService.saveDownloadedBook(
        book,
        pdfBytes,
        sourceUrl: sourceUrl,
      );
    } finally {
      _persistingIds.remove(book.id);
      notifyListeners();
    }
  }

  Future<void> removeDownloadedBook(String bookId) async {
    await _readerLibraryService.removeDownloadedBook(bookId);
    notifyListeners();
  }

  Future<void> setLastPage(String bookId, int page) async {
    await _readerLibraryService.setLastPage(bookId, page);
  }

  Future<void> addRecentBook(BookModel book, int page) async {
    await _readerLibraryService.addRecentBook(book, page);
    notifyListeners();
  }

  Future<void> saveWeeklyPlan(List<WeeklyPlanItem> items) async {
    await _readerLibraryService.saveWeeklyPlan(items);
    notifyListeners();
  }

  Future<void> setScrollDirection(String bookId, String direction) async {
    await _readerLibraryService.setScrollDirection(bookId, direction);
    notifyListeners();
  }

  Future<bool> toggleBookmark(String bookId, int page) async {
    final isBookmarked =
        await _readerLibraryService.toggleBookmark(bookId, page);
    notifyListeners();
    return isBookmarked;
  }

  Future<void> saveNote(String bookId, int page, String text) async {
    await _readerLibraryService.saveNote(bookId, page, text);
    notifyListeners();
  }

  Future<void> removeNote(String bookId, int page) async {
    await _readerLibraryService.removeNote(bookId, page);
    notifyListeners();
  }
}
