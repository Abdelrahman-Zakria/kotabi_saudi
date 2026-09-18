import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/kotbi_1447_models.dart';

class Kotbi1447CatalogService {
  Kotbi1447CatalogService._();

  static final Kotbi1447CatalogService instance = Kotbi1447CatalogService._();

  static const String _assetPath = 'assets/data/holol-kottby.json';

  Kotbi1447Catalog? _catalog;

  Future<Kotbi1447Catalog> fetchCatalog() async {
    final cached = _catalog;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final catalog = Kotbi1447Catalog.fromJson(decoded);
    _catalog = catalog;
    return catalog;
  }

  Future<List<Kotbi1447Grade>> fetchGrades() async {
    final catalog = await fetchCatalog();
    return catalog.grades
        .where((grade) => grade.gradeId.isNotEmpty && grade.resourceCount > 0)
        .toList();
  }
}
