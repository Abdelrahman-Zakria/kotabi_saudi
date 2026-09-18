import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';

class InAppVideoPlayerScreen extends StatefulWidget {
  final String title;
  final String url;

  const InAppVideoPlayerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<InAppVideoPlayerScreen> createState() => _InAppVideoPlayerScreenState();
}

class _InAppVideoPlayerScreenState extends State<InAppVideoPlayerScreen> {
  YoutubePlayerController? _controller;
  String? _videoId;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (_videoId == null || _videoId!.trim().isEmpty) {
      _hasError = true;
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style:
              const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: controller == null
                ? null
                : () {
                    final videoId = YoutubePlayer.convertUrlToId(widget.url);
                    if (videoId == null || videoId.trim().isEmpty) {
                      setState(() => _hasError = true);
                      return;
                    }
                    setState(() => _hasError = false);
                    controller.load(videoId);
                    controller.play();
                  },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError && controller != null)
            Center(
              child: YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppColors.primary,
                  progressColors: const ProgressBarColors(
                    playedColor: AppColors.primary,
                    handleColor: AppColors.primary,
                    bufferedColor: Colors.white54,
                    backgroundColor: Colors.white24,
                  ),
                  bottomActions: const [
                    CurrentPosition(),
                    ProgressBar(isExpanded: true),
                    RemainingDuration(),
                  ],
                ),
                builder: (context, player) {
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: player,
                  );
                },
              ),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.video_library_rounded,
                      color: Colors.white70,
                      size: 44,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'تعذر تشغيل الفيديو داخل التطبيق',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'الرابط الحالي ليس رابط YouTube صالحًا أو لم نتمكن من استخراج معرف الفيديو.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
