import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/services/ktbby_images_service.dart';

/// The visual for a grade-selection card. When [gradeId] is provided the
/// grade artwork published on ktbbysaa.com is shown; the generated gradient
/// badge below is used while it loads and whenever it is unavailable.
class GradeBadge extends StatelessWidget {
  final int gradeNumber;
  final Color color;
  final String? gradeId;

  const GradeBadge({
    super.key,
    required this.gradeNumber,
    required this.color,
    this.gradeId,
  });

  @override
  Widget build(BuildContext context) {
    final id = gradeId?.trim() ?? '';
    if (id.isEmpty) return _buildGeneratedBadge();

    return Padding(
      padding: const EdgeInsets.all(6),
      child: CachedNetworkImage(
        imageUrl: KtbbyImagesService.gradeImageUrl(id),
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, __) => _buildGeneratedBadge(),
        errorWidget: (_, __, ___) => _buildGeneratedBadge(),
      ),
    );
  }

  Widget _buildGeneratedBadge() {
    return Center(
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, Color.lerp(color, Colors.black, 0.18)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$gradeNumber',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 16,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
