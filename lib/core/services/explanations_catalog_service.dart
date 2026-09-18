import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/explanations_catalog_models.dart';

class ExplanationsCatalogService {
  ExplanationsCatalogService._();

  static final ExplanationsCatalogService instance =
      ExplanationsCatalogService._();

  static const String _assetPath = 'assets/explanations_catalog.json';

  bool _loaded = false;
  List<ExplanationSemester> _semesters = [];

  Future<void> initialize() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final semesters = (decoded['semesters'] as List<dynamic>? ?? const [])
        .map((e) => ExplanationSemester.fromJson(e as Map<String, dynamic>))
        .where((s) => !_isSemesterThree(s.name))
        .where((s) => s.name.trim().isNotEmpty && s.grades.isNotEmpty)
        .toList();

    _semesters = semesters;
    _loaded = true;
  }

  Future<List<ExplanationSemester>> fetchSemesters() async {
    await initialize();
    return _semesters;
  }

  Future<ExplanationSemester?> findSemester(String semesterName) async {
    await initialize();
    return _semesters.cast<ExplanationSemester?>().firstWhere(
          (s) => s != null && _norm(s.name) == _norm(semesterName),
          orElse: () => null,
        );
  }

  String _norm(String text) {
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

  bool _isSemesterThree(String semesterName) {
    final normalized = _norm(semesterName);
    return normalized == _norm('الفصل الدراسي الثالث') ||
        normalized == _norm('الفصل الثالث') ||
        normalized.contains(_norm('الثالث'));
  }
}
