import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kotabi_saudi/core/new_ui/app_constants.dart';
import 'package:kotabi_saudi/core/models/book_model.dart';

class BookPageNote {
  final int page;
  final String text;
  final DateTime updatedAt;

  const BookPageNote({
    required this.page,
    required this.text,
    required this.updatedAt,
  });

  factory BookPageNote.fromJson(Map<String, dynamic> json) {
    return BookPageNote(
      page: json['page'] ?? 1,
      text: json['text'] ?? '',
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'text': text,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ReaderBookPreferences {
  final int lastPage;
  final String scrollDirection;
  final List<int> bookmarks;
  final List<BookPageNote> notes;

  const ReaderBookPreferences({
    this.lastPage = 1,
    this.scrollDirection = 'vertical',
    this.bookmarks = const [],
    this.notes = const [],
  });

  factory ReaderBookPreferences.fromJson(Map<String, dynamic> json) {
    return ReaderBookPreferences(
      lastPage: json['last_page'] ?? 1,
      scrollDirection: json['scroll_direction'] ?? 'vertical',
      bookmarks: (json['bookmarks'] as List<dynamic>? ?? const [])
          .map((page) => page as int)
          .toList()
        ..sort(),
      notes: (json['notes'] as List<dynamic>? ?? const [])
          .map((note) => BookPageNote.fromJson(note as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.page.compareTo(b.page)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_page': lastPage,
      'scroll_direction': scrollDirection,
      'bookmarks': bookmarks,
      'notes': notes.map((note) => note.toJson()).toList(),
    };
  }

  ReaderBookPreferences copyWith({
    int? lastPage,
    String? scrollDirection,
    List<int>? bookmarks,
    List<BookPageNote>? notes,
  }) {
    return ReaderBookPreferences(
      lastPage: lastPage ?? this.lastPage,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
    );
  }
}

class DownloadedBookEntry {
  final BookModel book;
  final String localPath;
  final DateTime downloadedAt;
  final String? sourceUrl;
  final int fileSizeBytes;

  const DownloadedBookEntry({
    required this.book,
    required this.localPath,
    required this.downloadedAt,
    this.sourceUrl,
    required this.fileSizeBytes,
  });

  factory DownloadedBookEntry.fromJson(Map<String, dynamic> json) {
    return DownloadedBookEntry(
      book: BookModel.fromJson(json['book'] as Map<String, dynamic>),
      localPath: json['local_path'] ?? '',
      downloadedAt:
          DateTime.tryParse(json['downloaded_at'] ?? '') ?? DateTime.now(),
      sourceUrl: json['source_url'],
      fileSizeBytes: json['file_size_bytes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book.toJson(),
      'local_path': localPath,
      'downloaded_at': downloadedAt.toIso8601String(),
      'source_url': sourceUrl,
      'file_size_bytes': fileSizeBytes,
    };
  }

  DownloadedBookEntry copyWith({
    BookModel? book,
    String? localPath,
    DateTime? downloadedAt,
    String? sourceUrl,
    int? fileSizeBytes,
  }) {
    return DownloadedBookEntry(
      book: book ?? this.book,
      localPath: localPath ?? this.localPath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }
}

class RecentBookEntry {
  final BookModel book;
  final int lastPage;
  final DateTime viewedAt;

  const RecentBookEntry({
    required this.book,
    required this.lastPage,
    required this.viewedAt,
  });

  factory RecentBookEntry.fromJson(Map<String, dynamic> json) {
    return RecentBookEntry(
      book: BookModel.fromJson(json['book'] as Map<String, dynamic>),
      lastPage: json['last_page'] ?? 1,
      viewedAt: DateTime.tryParse(json['viewed_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book.toJson(),
      'last_page': lastPage,
      'viewed_at': viewedAt.toIso8601String(),
    };
  }
}

class WeeklyPlanItem {
  final String dayId;
  final String title;
  final String focus;

  const WeeklyPlanItem({
    required this.dayId,
    required this.title,
    required this.focus,
  });

  factory WeeklyPlanItem.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanItem(
      dayId: json['day_id'] ?? '',
      title: json['title'] ?? '',
      focus: json['focus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_id': dayId,
      'title': title,
      'focus': focus,
    };
  }
}

class ReaderLibraryService {
  static final ReaderLibraryService _instance =
      ReaderLibraryService._internal();
  factory ReaderLibraryService() => _instance;
  ReaderLibraryService._internal();

  final Map<String, DownloadedBookEntry> _downloadedBooks = {};
  final Map<String, ReaderBookPreferences> _readerPreferences = {};
  final List<RecentBookEntry> _recentBooks = [];
  final Map<String, WeeklyPlanItem> _weeklyPlan = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _loadDownloadedBooks();
    await _loadReaderPreferences();
    await _loadRecentBooks();
    await _loadWeeklyPlan();
    _initialized = true;
  }

  List<DownloadedBookEntry> get downloadedBooks {
    final books = _downloadedBooks.values.toList()
      ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return List.unmodifiable(books);
  }

  DownloadedBookEntry? getDownloadedBook(String bookId) {
    return _downloadedBooks[bookId];
  }

  bool isDownloaded(String bookId) => _downloadedBooks.containsKey(bookId);

  List<RecentBookEntry> get recentBooks => List.unmodifiable(_recentBooks);

  List<WeeklyPlanItem> get weeklyPlan {
    final items = _weeklyPlan.values.toList()
      ..sort((a, b) => _dayOrder(a.dayId).compareTo(_dayOrder(b.dayId)));
    return List.unmodifiable(items);
  }

  int get totalBookmarksCount {
    return _readerPreferences.values.fold<int>(
      0,
      (sum, prefs) => sum + prefs.bookmarks.length,
    );
  }

  int get totalNotesCount {
    return _readerPreferences.values.fold<int>(
      0,
      (sum, prefs) => sum + prefs.notes.length,
    );
  }

  int get booksWithProgressCount {
    return _readerPreferences.values
        .where((prefs) => prefs.lastPage > 1)
        .length;
  }

  int getLastPage(String bookId) {
    return _readerPreferences[bookId]?.lastPage ?? 1;
  }

  String getScrollDirection(String bookId) {
    return _readerPreferences[bookId]?.scrollDirection ?? 'vertical';
  }

  List<int> getBookmarks(String bookId) {
    return List.unmodifiable(_readerPreferences[bookId]?.bookmarks ?? const []);
  }

  List<BookPageNote> getNotes(String bookId) {
    return List.unmodifiable(_readerPreferences[bookId]?.notes ?? const []);
  }

  BookPageNote? getNoteForPage(String bookId, int page) {
    for (final note
        in _readerPreferences[bookId]?.notes ?? const <BookPageNote>[]) {
      if (note.page == page) return note;
    }
    return null;
  }

  Future<DownloadedBookEntry> saveDownloadedBook(
    BookModel book,
    Uint8List pdfBytes, {
    String? sourceUrl,
  }) async {
    if (pdfBytes.isEmpty) {
      throw const FileSystemException('Cannot save an empty PDF file');
    }

    final file = await _fileForBook(book.id);
    await file.create(recursive: true);
    await file.writeAsBytes(pdfBytes, flush: true);

    if (!await file.exists()) {
      throw FileSystemException('PDF file was not written', file.path);
    }

    final entry = DownloadedBookEntry(
      book: book,
      localPath: file.path,
      downloadedAt: DateTime.now(),
      sourceUrl: sourceUrl,
      fileSizeBytes: pdfBytes.lengthInBytes,
    );

    _downloadedBooks[book.id] = entry;
    await _saveDownloadedBooks();
    return entry;
  }

  Future<void> updateDownloadedDocument(
      String bookId, Uint8List pdfBytes) async {
    final existing = _downloadedBooks[bookId];
    if (existing == null) return;

    final file = File(existing.localPath);
    await file.writeAsBytes(pdfBytes, flush: true);
    _downloadedBooks[bookId] = existing.copyWith(
      fileSizeBytes: pdfBytes.lengthInBytes,
      downloadedAt: DateTime.now(),
    );
    await _saveDownloadedBooks();
  }

  Future<void> removeDownloadedBook(String bookId) async {
    final entry = _downloadedBooks.remove(bookId);
    if (entry != null) {
      final file = File(entry.localPath);
      if (await file.exists()) {
        await file.delete();
      }
      await _saveDownloadedBooks();
    }
  }

  Future<void> setLastPage(String bookId, int page) async {
    final prefs = _preferencesFor(bookId).copyWith(lastPage: page);
    _readerPreferences[bookId] = prefs;
    await _saveReaderPreferences();
  }

  Future<void> addRecentBook(BookModel book, int page) async {
    _recentBooks.removeWhere((entry) => entry.book.id == book.id);
    _recentBooks.insert(
      0,
      RecentBookEntry(
        book: book,
        lastPage: page,
        viewedAt: DateTime.now(),
      ),
    );
    if (_recentBooks.length > 12) {
      _recentBooks.removeRange(12, _recentBooks.length);
    }
    await _saveRecentBooks();
  }

  Future<void> saveWeeklyPlan(List<WeeklyPlanItem> items) async {
    _weeklyPlan
      ..clear()
      ..addEntries(items.map((item) => MapEntry(item.dayId, item)));
    await _saveWeeklyPlan();
  }

  Future<void> setScrollDirection(String bookId, String direction) async {
    final prefs = _preferencesFor(bookId).copyWith(scrollDirection: direction);
    _readerPreferences[bookId] = prefs;
    await _saveReaderPreferences();
  }

  Future<bool> toggleBookmark(String bookId, int page) async {
    final prefs = _preferencesFor(bookId);
    final bookmarks = prefs.bookmarks.toList();
    final wasBookmarked = bookmarks.contains(page);

    if (wasBookmarked) {
      bookmarks.remove(page);
    } else {
      bookmarks.add(page);
      bookmarks.sort();
    }

    _readerPreferences[bookId] = prefs.copyWith(bookmarks: bookmarks);
    await _saveReaderPreferences();
    return !wasBookmarked;
  }

  Future<void> saveNote(String bookId, int page, String text) async {
    final prefs = _preferencesFor(bookId);
    final notes = prefs.notes.where((note) => note.page != page).toList();

    if (text.trim().isNotEmpty) {
      notes.add(
        BookPageNote(
          page: page,
          text: text.trim(),
          updatedAt: DateTime.now(),
        ),
      );
      notes.sort((a, b) => a.page.compareTo(b.page));
    }

    _readerPreferences[bookId] = prefs.copyWith(notes: notes);
    await _saveReaderPreferences();
  }

  Future<void> removeNote(String bookId, int page) async {
    final prefs = _preferencesFor(bookId);
    final notes = prefs.notes.where((note) => note.page != page).toList();
    _readerPreferences[bookId] = prefs.copyWith(notes: notes);
    await _saveReaderPreferences();
  }

  ReaderBookPreferences _preferencesFor(String bookId) {
    return _readerPreferences[bookId] ?? const ReaderBookPreferences();
  }

  Future<void> _loadDownloadedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(AppConstants.keyDownloadedBooks);
      if (rawJson == null || rawJson.isEmpty) return;

      final decoded = jsonDecode(rawJson) as List<dynamic>;
      for (final item in decoded) {
        final entry =
            DownloadedBookEntry.fromJson(item as Map<String, dynamic>);
        if (await File(entry.localPath).exists()) {
          _downloadedBooks[entry.book.id] = entry;
        }
      }

      await _saveDownloadedBooks();
    } catch (_) {
      _downloadedBooks.clear();
    }
  }

  Future<void> _saveDownloadedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = jsonEncode(
      _downloadedBooks.values.map((entry) => entry.toJson()).toList(),
    );
    await prefs.setString(AppConstants.keyDownloadedBooks, rawJson);
  }

  Future<void> _loadReaderPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(AppConstants.keyReaderPreferences);
      if (rawJson == null || rawJson.isEmpty) return;

      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      decoded.forEach((bookId, value) {
        _readerPreferences[bookId] =
            ReaderBookPreferences.fromJson(value as Map<String, dynamic>);
      });
    } catch (_) {
      _readerPreferences.clear();
    }
  }

  Future<void> _loadRecentBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(AppConstants.keyLastViewedBooks);
      if (rawJson == null || rawJson.isEmpty) return;

      final decoded = jsonDecode(rawJson) as List<dynamic>;
      _recentBooks
        ..clear()
        ..addAll(
          decoded.map(
            (item) => RecentBookEntry.fromJson(item as Map<String, dynamic>),
          ),
        );
    } catch (_) {
      _recentBooks.clear();
    }
  }

  Future<void> _saveRecentBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyLastViewedBooks,
      jsonEncode(_recentBooks.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> _loadWeeklyPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(AppConstants.keyWeeklyStudyPlan);
      if (rawJson == null || rawJson.isEmpty) return;
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      _weeklyPlan
        ..clear()
        ..addEntries(
          decoded.map((item) {
            final plan = WeeklyPlanItem.fromJson(item as Map<String, dynamic>);
            return MapEntry(plan.dayId, plan);
          }),
        );
    } catch (_) {
      _weeklyPlan.clear();
    }
  }

  Future<void> _saveWeeklyPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyWeeklyStudyPlan,
      jsonEncode(_weeklyPlan.values.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _saveReaderPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = jsonEncode(
      _readerPreferences.map(
        (bookId, prefs) => MapEntry(bookId, prefs.toJson()),
      ),
    );
    await prefs.setString(AppConstants.keyReaderPreferences, rawJson);
  }

  Future<File> _fileForBook(String bookId) async {
    final baseDir = Directory(
      '${Directory.systemTemp.path}/kutub_madrasiyya',
    );
    final booksDir = Directory('${baseDir.path}/downloaded_books');
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    final safeBookId = _safeFileName(bookId);
    return File('${booksDir.path}/$safeBookId.pdf');
  }

  String _safeFileName(String input) {
    final safe = input.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
    if (safe.trim().isEmpty) {
      return 'book_${input.hashCode.abs()}';
    }
    return safe.length > 90 ? safe.substring(0, 90) : safe;
  }

  int _dayOrder(String dayId) {
    const order = {
      'sun': 0,
      'mon': 1,
      'tue': 2,
      'wed': 3,
      'thu': 4,
      'fri': 5,
      'sat': 6,
    };
    return order[dayId] ?? 99;
  }
}
