import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/models/book_model.dart';
import 'package:kotabi_saudi/core/services/ktbby_images_service.dart';

/// Shows a catalog item's cover art, loaded from ktbbysaa.com and cached on
/// device. Falls back to the bundled copy of the same image when the network
/// is unavailable, and to [fallback] when the item has no artwork at all.
class BookCoverImage extends StatelessWidget {
  final BookModel book;
  final BoxFit fit;
  final Widget fallback;

  const BookCoverImage({
    super.key,
    required this.book,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final remoteUrl = KtbbyImagesService.bookImageUrl(book);
    final bundledAsset = KtbbyImagesService.bundledAssetFor(book);

    if (remoteUrl == null) {
      return bundledAsset == null
          ? fallback
          : Image.asset(
              bundledAsset,
              fit: fit,
              errorBuilder: (_, __, ___) => fallback,
            );
    }

    return CachedNetworkImage(
      imageUrl: remoteUrl,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => _offlineFallback(bundledAsset),
      errorWidget: (_, __, ___) => _offlineFallback(bundledAsset),
    );
  }

  Widget _offlineFallback(String? bundledAsset) {
    if (bundledAsset == null) return fallback;
    return Image.asset(
      bundledAsset,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
