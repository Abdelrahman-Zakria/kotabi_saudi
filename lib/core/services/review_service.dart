import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:kotabi_saudi/core/services/ad_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;
  GlobalKey<NavigatorState>? navigatorKey;
  Timer? _reviewTimer;
  Timer? _initialReviewTimer;
  bool _isPromptShowing = false;
  bool _isRequestingReview = false;

  Future<void> init() async {
    showInitialReviewPrompt();
    startPeriodicReviewRequests();
  }

  void showInitialReviewPrompt() {
    _initialReviewTimer?.cancel();
    _initialReviewTimer = Timer(const Duration(seconds: 10), () {
      showReviewPrompt();
    });
  }

  void startPeriodicReviewRequests() {
    _reviewTimer?.cancel();
    _reviewTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      showReviewPrompt();
    });
  }

  Future<void> showReviewPrompt() async {
    if (_isPromptShowing || AdService().isFullScreenAdShowing) return;

    final context = navigatorKey?.currentContext;
    if (context == null) return;

    _isPromptShowing = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.star_rate_rounded, color: Color(0xFFFFB300)),
                  SizedBox(width: 8),
                  Expanded(child: Text('قيّم تطبيق كتبي')),
                ],
              ),
              content: const Text(
                'إذا أعجبك التطبيق، قيّمنا في المتجر وساعدنا نطوره أكثر.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('لاحقًا'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await requestReview();
                  },
                  icon: const Icon(Icons.star_rounded),
                  label: const Text('قيّم الآن'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      _isPromptShowing = false;
    }
  }

  Future<void> requestReview() async {
    if (_isRequestingReview || AdService().isFullScreenAdShowing) return;

    _isRequestingReview = true;
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        await _inAppReview.requestReview();
      } else {
        dev.log('Native in-app review is not available on this device.');
      }
    } catch (e) {
      dev.log('In-app review request failed: $e');
    } finally {
      _isRequestingReview = false;
    }
  }

  void dispose() {
    _initialReviewTimer?.cancel();
    _reviewTimer?.cancel();
  }
}
