import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/book_model.dart';
import '../models/grade_model.dart';

class HululiCatalogService {
  HululiCatalogService._();

  static final HululiCatalogService instance = HululiCatalogService._();

  static const String _assetPath = 'assets/hululi_catalog.json';

  bool _loaded = false;
  List<BookModel> _items = [];
  final Map<String, List<BookModel>> _byGrade = {};
  final Map<String, int> _gradeCounts = {};

  Future<void> initialize() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final items = (decoded['items'] as List<dynamic>? ?? const [])
        .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
        .where((item) => item.id.trim().isNotEmpty)
        .toList();

    _items = items;
    _gradeCounts
      ..clear()
      ..addAll(_buildGradeCounts(items));
    _loaded = true;
  }

  Future<List<BookModel>> fetchBooksForGrade(String gradeId) async {
    await initialize();

    if (_byGrade.containsKey(gradeId)) {
      return _byGrade[gradeId]!;
    }

    final items = _items.where((item) => item.grade == gradeId).toList()
      ..sort(_compareBooks);

    _byGrade[gradeId] = items;
    return items;
  }

  Future<List<HululiGradeEntry>> fetchGrades() async {
    await initialize();

    final gradeIds = _gradeCounts.keys.toSet();
    final grades = gradeIds
        .map(GradeModel.getById)
        .whereType<GradeModel>()
        .toList()
      ..sort((a, b) => a.gradeNumber.compareTo(b.gradeNumber));

    return grades
        .map(
          (grade) => HululiGradeEntry(
            grade: grade,
            count: _gradeCounts[grade.id] ?? 0,
          ),
        )
        .where((entry) => entry.count > 0)
        .toList();
  }

  Map<String, int> _buildGradeCounts(List<BookModel> items) {
    final counts = <String, int>{};
    for (final item in items) {
      final gradeId = item.grade.trim();
      if (gradeId.isEmpty) continue;
      counts[gradeId] = (counts[gradeId] ?? 0) + 1;
    }
    return counts;
  }

  int _compareBooks(BookModel a, BookModel b) {
    final semesterCompare =
        _semesterPriority(a.semester).compareTo(_semesterPriority(b.semester));
    if (semesterCompare != 0) return semesterCompare;

    final subjectCompare = a.subject.compareTo(b.subject);
    if (subjectCompare != 0) return subjectCompare;

    final typeCompare = _contentTypePriority(a.contentType)
        .compareTo(_contentTypePriority(b.contentType));
    if (typeCompare != 0) return typeCompare;

    return a.title.compareTo(b.title);
  }

  int _semesterPriority(String semester) {
    final normalized = _normalize(semester);
    if (normalized == _normalize('الفصل الأول')) return 0;
    if (normalized == _normalize('الفصل الثاني')) return 1;
    if (normalized == _normalize('الفصل الثالث')) return 2;
    return 99;
  }

  int _contentTypePriority(String type) {
    const priorities = {
      'solution': 0,
      'worksheet': 1,
      'exam': 2,
      'summary': 3,
      'distribution': 4,
      'preparation': 5,
      'presentation': 6,
      'content': 7,
      'book': 8,
    };
    return priorities[type] ?? 99;
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
}

class HululiGradeEntry {
  final GradeModel grade;
  final int count;

  const HululiGradeEntry({
    required this.grade,
    required this.count,
  });
}
