import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/models/explanations_catalog_models.dart';
import 'in_app_video_player_screen.dart';

class ExplanationsChaptersScreen extends StatelessWidget {
  final ExplanationSemester semester;
  final ExplanationGrade grade;
  final ExplanationSubject subject;

  const ExplanationsChaptersScreen({
    super.key,
    required this.semester,
    required this.grade,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final chapters = subject.chapters;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          subject.name,
          style:
              const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: chapters.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          final videoCount = chapter.youtubeLinks.length;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openChapter(context, chapter),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          if (videoCount > 1) ...[
                            const SizedBox(height: 4),
                            Text(
                              '$videoCount فيديو',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openChapter(
      BuildContext context, ExplanationChapter chapter) async {
    final links = chapter.youtubeLinks;
    if (links.isEmpty) return;

    if (links.length == 1) {
      _openVideo(context, title: chapter.title, url: links.first);
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            itemCount: links.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final url = links[index];
              return ListTile(
                onTap: () => Navigator.of(ctx).pop(url),
                leading: const Icon(Icons.play_arrow_rounded),
                title: Text(
                  'فيديو ${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  chapter.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              );
            },
          ),
        );
      },
    );

    if (selected == null || !context.mounted) return;
    _openVideo(context, title: chapter.title, url: selected);
  }

  void _openVideo(BuildContext context,
      {required String title, required String url}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InAppVideoPlayerScreen(title: title, url: url),
      ),
    );
  }
}
