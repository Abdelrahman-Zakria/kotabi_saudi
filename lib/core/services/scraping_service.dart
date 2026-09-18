import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class ScrapingService {
  static final ScrapingService _instance = ScrapingService._internal();
  factory ScrapingService() => _instance;
  ScrapingService._internal();

  static const String _catalogAssetPath = 'assets/data/content_catalog.json';
  static const String _ktbbyCatalogUrl =
      'https://ktbbysaa.com/assets/data/catalog.json';
  static const String _ktbby1448CatalogUrl =
      'https://ktbbysaa.com/assets/data/kutub_1448.json';
  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'ar,en;q=0.8',
  };

  List<BookModel> _allItems = [];
  final Map<String, List<BookModel>> _cache = {};
  final Map<String, String?> _gradeThumbnailCache = {};
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(_catalogAssetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final localItems = (decoded['items'] as List<dynamic>? ?? const [])
        .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
        .where(_isVisibleItem)
        .toList();

    final itemsByKey = <String, BookModel>{};
    for (final item in localItems) {
      itemsByKey[_dedupeKey(item)] = item;
    }

    for (final item in await _loadKtbbyItems()) {
      if (_isVisibleItem(item)) {
        itemsByKey[_dedupeKey(item)] = item;
      }
    }

    _allItems = itemsByKey.values.toList();
    _loaded = true;
  }

  Future<List<BookModel>> fetchBooksForGrade({
    required String gradeId,
    required String wajibiPath,
  }) async {
    await initialize();

    if (_cache.containsKey(gradeId)) {
      return _cache[gradeId]!;
    }

    final items = _allItems.where((item) => item.grade == gradeId).toList()
      ..sort((a, b) {
        final typeCompare = _contentTypePriority(a.contentType)
            .compareTo(_contentTypePriority(b.contentType));
        if (typeCompare != 0) return typeCompare;
        return a.title.compareTo(b.title);
      });

    _cache[gradeId] = items;
    return items;
  }

  Future<List<BookModel>> searchBooks(String query) async {
    await initialize();
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return [];

    return _allItems.where((item) {
      return _isVisibleItem(item) &&
          (_normalize(item.title).contains(normalizedQuery) ||
              _normalize(item.subject).contains(normalizedQuery) ||
              _normalize(item.grade).contains(normalizedQuery) ||
              _normalize(item.contentType).contains(normalizedQuery));
    }).toList();
  }

  Future<String?> getRepresentativeThumbnailForGrade(String gradeId) async {
    await initialize();

    if (_gradeThumbnailCache.containsKey(gradeId)) {
      return _gradeThumbnailCache[gradeId];
    }

    final candidate = _allItems.cast<BookModel?>().firstWhere(
          (item) =>
              item != null &&
              item.grade == gradeId &&
              item.thumbnailAsset != null &&
              item.thumbnailAsset!.isNotEmpty &&
              item.contentType == 'book',
          orElse: () => null,
        );

    final fallback = candidate ??
        _allItems.cast<BookModel?>().firstWhere(
              (item) =>
                  item != null &&
                  item.grade == gradeId &&
                  item.thumbnailAsset != null &&
                  item.thumbnailAsset!.isNotEmpty,
              orElse: () => null,
            );

    final thumbnail = fallback?.thumbnailAsset;
    _gradeThumbnailCache[gradeId] = thumbnail;
    return thumbnail;
  }

  Future<String?> resolveBookPdfUrl(BookModel book) async {
    final candidates = <String>{
      book.pdfUrl.trim(),
      (book.pageUrl ?? '').trim(),
    }..removeWhere((url) => url.isEmpty);

    for (final url in candidates) {
      final resolved = await _resolvePdfOrPageUrl(url);
      if (resolved != null) return resolved;
    }

    return _searchForUpdatedPdfUrl(book);
  }

  Future<String?> _resolvePdfOrPageUrl(String url) async {
    if (_looksLikePdfUrl(url)) return url;

    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return null;
      return _extractPdfUrlFromHtml(response.body, baseUrl: url);
    } catch (_) {
      return null;
    }
  }

  String? _extractPdfUrlFromHtml(String html, {String? baseUrl}) {
    final document = html_parser.parse(html);

    for (final element in document.querySelectorAll(
      'a[href], embed[src], object[data], source[src]',
    )) {
      final href = element.attributes['href'] ??
          element.attributes['src'] ??
          element.attributes['data'];
      final resolved = _resolveMaybeRelativeUrl(href, baseUrl);
      if (resolved != null && _looksLikePdfUrl(resolved)) return resolved;
    }

    final metaRefresh = document
        .querySelectorAll('meta[http-equiv]')
        .cast<Element?>()
        .firstWhere(
          (element) =>
              element?.attributes['http-equiv']?.toLowerCase() == 'refresh',
          orElse: () => null,
        )
        ?.attributes['content'];
    final refreshUrl = RegExp(r'url=([^;]+)', caseSensitive: false)
        .firstMatch(metaRefresh ?? '')
        ?.group(1)
        ?.trim();
    final resolvedRefreshUrl = _resolveMaybeRelativeUrl(refreshUrl, baseUrl);
    if (resolvedRefreshUrl != null && _looksLikePdfUrl(resolvedRefreshUrl)) {
      return resolvedRefreshUrl;
    }

    for (final link in document.querySelectorAll('[data-pdf], [data-file]')) {
      final href = link.attributes['href'];
      final dataPdf =
          link.attributes['data-pdf'] ?? link.attributes['data-file'];
      final resolved = _resolveMaybeRelativeUrl(dataPdf ?? href, baseUrl);
      if (resolved != null && _looksLikePdfUrl(resolved)) return resolved;
    }

    final iframe = document.querySelector('iframe[src*="viewer.html?file="]') ??
        document.querySelector('iframe[data-lazy-src*="viewer.html?file="]') ??
        document.querySelector('iframe[src*="file="]') ??
        document.querySelector('iframe[data-lazy-src*="file="]') ??
        document.querySelector('iframe[src*=".pdf"]') ??
        document.querySelector('iframe[data-lazy-src*=".pdf"]');

    final iframeSrc =
        iframe?.attributes['src'] ?? iframe?.attributes['data-lazy-src'];
    if (iframeSrc == null || iframeSrc.isEmpty) return null;

    final iframeUri = _resolveMaybeRelativeUrl(iframeSrc, baseUrl);
    final fileParam = iframeUri == null
        ? null
        : Uri.tryParse(iframeUri)?.queryParameters['file'];
    final decodedFileParam =
        fileParam == null ? null : Uri.decodeFull(fileParam);
    final resolvedFileParam =
        _resolveMaybeRelativeUrl(decodedFileParam, baseUrl);
    if (resolvedFileParam != null && _looksLikePdfUrl(resolvedFileParam)) {
      return resolvedFileParam;
    }
    if (iframeUri != null && _looksLikePdfUrl(iframeUri)) return iframeUri;

    return null;
  }

  Future<List<BookModel>> _loadKtbbyItems() async {
    final items = <BookModel>[];

    try {
      final response = await http
          .get(Uri.parse(_ktbbyCatalogUrl), headers: _headers)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        items.addAll(
          (decoded['items'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(_bookFromKtbbyJson)
              .whereType<BookModel>(),
        );
      }
    } catch (_) {
      // The bundled catalog remains available offline.
    }

    try {
      final response = await http
          .get(Uri.parse(_ktbby1448CatalogUrl), headers: _headers)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        items.addAll(
          (decoded['books'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(_bookFromKtbbyJson)
              .whereType<BookModel>(),
        );
      }
    } catch (_) {
      // The first catalog and bundled data are still enough for browsing.
    }

    return items;
  }

  BookModel? _bookFromKtbbyJson(Map<String, dynamic> json) {
    final title = _stringValue(json['title'] ?? json['shortTitle']);
    final pdfUrl = _stringValue(json['pdf_url']);
    if (title.isEmpty || pdfUrl.isEmpty) return null;

    final id = _stringValue(json['id']).isNotEmpty
        ? _stringValue(json['id'])
        : 'ktbby_${title.hashCode}_${pdfUrl.hashCode}';
    final grade = _normalizeGradeId(
      _stringValue(json['grade']),
      gradeName: _stringValue(json['gradeName']),
      title: title,
      treePath: _stringValue(json['treePath']),
    );

    return BookModel(
      id: id,
      title: title,
      subject: _cleanSubject(_stringValue(json['subject'])),
      grade: grade,
      stage: _stringValue(json['stage']),
      semester: _normalizeSemester(_stringValue(json['semester'])),
      pdfUrl: pdfUrl,
      pageUrl: _buildKtbbyPageUrl(json),
      contentType: _normalizeContentType(
        _stringValue(json['content_type']).isNotEmpty
            ? _stringValue(json['content_type'])
            : _stringValue(json['typeLabel']),
      ),
      thumbnailUrl: _stringValue(json['thumbnail']),
      pageCount: json['page_count'] is int ? json['page_count'] as int : null,
      fileSize: _stringValue(json['file_size']),
    );
  }

  String? _buildKtbbyPageUrl(Map<String, dynamic> json) {
    final pageUrl = _stringValue(json['page_url']);
    if (pageUrl.isNotEmpty) return pageUrl;

    final slug = _stringValue(json['slug']);
    if (slug.isEmpty) return null;
    return 'https://ktbbysaa.com/book/$slug';
  }

  String _normalizeGradeId(
    String grade, {
    required String gradeName,
    required String title,
    required String treePath,
  }) {
    if (RegExp(r'^grade(?:[1-9]|1[0-2])$').hasMatch(grade)) return grade;

    final text = _normalize('$grade $gradeName $title $treePath');
    if (text.contains('الاول الابتدائي')) return 'grade1';
    if (text.contains('الثاني الابتدائي')) return 'grade2';
    if (text.contains('الثالث الابتدائي')) return 'grade3';
    if (text.contains('الرابع الابتدائي')) return 'grade4';
    if (text.contains('الخامس الابتدائي')) return 'grade5';
    if (text.contains('السادس الابتدائي')) return 'grade6';
    if (text.contains('الاول المتوسط')) return 'grade7';
    if (text.contains('الثاني المتوسط')) return 'grade8';
    if (text.contains('الثالث المتوسط')) return 'grade9';
    if (text.contains('الاول الثانوي')) return 'grade10';
    if (text.contains('الثاني الثانوي')) return 'grade11';
    if (text.contains('الثالث الثانوي')) return 'grade12';
    return grade;
  }

  String _normalizeSemester(String semester) {
    final text = _normalize(semester);
    final hasFirst = text.contains('الاول') || text.contains('ف1');
    final hasSecond = text.contains('الثاني') || text.contains('ف2');
    if (hasFirst && hasSecond) return 'الفصل الأول والثاني';
    if (hasFirst) return 'الفصل الأول';
    if (hasSecond) return 'الفصل الثاني';
    return semester;
  }

  String _normalizeContentType(String type) {
    final text = _normalize(type);
    if (text.contains('حل')) return 'solution';
    if (text.contains('اختبار') || text == 'exam_periodic') return 'exam';
    if (text.contains('ملخص')) return 'summary';
    if (text.contains('ورق')) return 'worksheet';
    if (text.contains('توزيع')) return 'distribution';
    if (text.contains('تحضير')) return 'preparation';
    if (text.contains('عرض')) return 'presentation';
    if (text.contains('شرح')) return 'content';
    if (text.contains('كتاب') || text.contains('book')) return 'book';
    return type.isEmpty ? 'content' : type;
  }

  String _cleanSubject(String subject) {
    return subject.replaceFirst(RegExp(r'^مادة\s+'), '').trim();
  }

  String _stringValue(Object? value) => value?.toString().trim() ?? '';

  String _dedupeKey(BookModel item) {
    final pdf = item.pdfUrl.trim();
    if (pdf.isNotEmpty) return 'pdf:${pdf.toLowerCase()}';
    return 'item:${item.id}';
  }

  String? _resolveMaybeRelativeUrl(String? url, String? baseUrl) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = _decodeHtmlUrl(url.trim());
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;
    if (parsed.hasScheme) return trimmed;
    final base = baseUrl == null ? null : Uri.tryParse(baseUrl);
    if (base == null) return trimmed;
    return base.resolveUri(parsed).toString();
  }

  String _decodeHtmlUrl(String url) {
    return url
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'");
  }

  Future<String?> _searchForUpdatedPdfUrl(BookModel book) async {
    final queries = <String>[
      book.title,
      '${book.subject} ${book.semester} ${book.grade}',
      '${book.subject} ${book.title}',
    ];

    for (final query in queries) {
      try {
        final uri = Uri.parse('https://wajibi.net')
            .replace(queryParameters: {'s': query});
        final response = await http
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 20));
        if (response.statusCode != 200) continue;

        final document = html_parser.parse(response.body);
        final links = document.querySelectorAll('a.kv-box-img, a.kv-box-title');
        final bestHref = _pickBestMatchingHref(links, book);
        if (bestHref == null) continue;

        final resolved = await _resolvePdfOrPageUrl(bestHref);
        if (resolved != null) return resolved;
      } catch (_) {
        // Try the next search query.
      }
    }

    return null;
  }

  String? _pickBestMatchingHref(List<Element> links, BookModel book) {
    final target = _normalize(book.title);
    String? bestHref;
    int bestScore = 0;

    for (final link in links) {
      final href = link.attributes['href'] ?? '';
      if (!href.startsWith('http')) continue;

      final title = _extractLinkTitle(link);
      if (title.isEmpty) continue;

      final normalizedTitle = _normalize(title);
      final score = _matchScore(target, normalizedTitle);
      if (score > bestScore) {
        bestScore = score;
        bestHref = href;
      }
    }

    return bestScore >= 2 ? bestHref : null;
  }

  String _extractLinkTitle(Element link) {
    final titleAttr = link.attributes['title']?.trim() ?? '';
    if (titleAttr.isNotEmpty) return titleAttr;

    final text = link.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isNotEmpty) return text;

    return link.querySelector('img')?.attributes['alt']?.trim() ?? '';
  }

  int _matchScore(String target, String candidate) {
    if (target == candidate) return 5;

    int score = 0;
    if (candidate.contains(target) || target.contains(candidate)) {
      score += 3;
    }

    final targetWords =
        target.split(' ').where((part) => part.isNotEmpty).toSet();
    final candidateWords =
        candidate.split(' ').where((part) => part.isNotEmpty).toSet();
    score += targetWords.intersection(candidateWords).length;

    return score;
  }

  bool _looksLikePdfUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.pdf') || lower.contains('.pdf?');
  }

  String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  int _contentTypePriority(String type) {
    const priorities = {
      'book': 0,
      'solution': 1,
      'exam': 2,
      'worksheet': 3,
      'summary': 4,
      'distribution': 5,
      'preparation': 6,
      'presentation': 7,
      'content': 8,
    };
    return priorities[type] ?? 99;
  }

  bool _isVisibleItem(BookModel item) {
    return !_isSemesterThree(item.semester) && !_isKindergarten(item.grade);
  }

  bool _isSemesterThree(String semester) {
    return _normalize(semester) == _normalize('الفصل الثالث');
  }

  bool _isKindergarten(String gradeId) {
    return gradeId.toLowerCase().startsWith('kg');
  }

  void clearCache() {
    _cache.clear();
    _gradeThumbnailCache.clear();
  }
}
