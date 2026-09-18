import '../models/book_model.dart';

/// Resolves every cover image the app shows — books, solutions and grade
/// cards — against the shared ktbbysaa.com asset host, so the app always
/// mirrors the artwork published on the website.
///
/// Catalog entries store their artwork as a site-relative path
/// (`assets/catalog_images/<hash>.jpg`, `assets/grade_images/grade7.png`);
/// those paths are turned into absolute ktbbysaa.com URLs here. Entries that
/// already carry an absolute URL are passed through untouched.
class KtbbyImagesService {
  KtbbyImagesService._();

  static const String host = 'https://ktbbysaa.com';

  /// Cover art for a grade card, e.g. `grade7` -> the site's grade artwork.
  static String gradeImageUrl(String gradeId) {
    final id = gradeId.trim();
    return '$host/assets/grade_images/$id.png';
  }

  /// Cover art for a book, solution, exam model or any other catalog item.
  /// Returns `null` when the item has no artwork at all.
  static String? bookImageUrl(BookModel book) {
    return remoteUrlFor(book.thumbnailAsset) ??
        remoteUrlFor(book.thumbnailUrl);
  }

  /// The bundled copy of a catalog image, used as an offline fallback while
  /// the remote cover loads or when the device is offline.
  static String? bundledAssetFor(BookModel book) {
    final asset = book.thumbnailAsset?.trim() ?? '';
    return asset.startsWith('assets/') ? asset : null;
  }

  /// Turns a catalog artwork reference into an absolute URL.
  static String? remoteUrlFor(String? reference) {
    final value = reference?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final path = value.startsWith('/') ? value.substring(1) : value;
    return '$host/$path';
  }
}
