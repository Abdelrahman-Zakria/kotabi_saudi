import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:kotabi_saudi/core/services/ad_service.dart';
import 'package:kotabi_saudi/core/services/iap_service.dart';

/// Renders the AdMob banner when one is available.
class AppAdBanner extends StatefulWidget {
  const AppAdBanner({super.key});

  @override
  State<AppAdBanner> createState() => _AppAdBannerState();
}

class _AppAdBannerState extends State<AppAdBanner> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerIfNeeded();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerIfNeeded() {
    // Check if user is premium
    if (IapService().isAdFree) {
      _disposeBanner();
      return;
    }

    if (_bannerAd != null) return;

    _bannerAd = AdService().createBannerAd()
      ?..load().then((_) {
        if (mounted) {
          setState(() => _isBannerLoaded = true);
        }
      }).catchError((e) {
        debugPrint('Banner load error: $e');
        _disposeBanner();
      });
  }

  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: IapService().adFreeStatusStream,
      initialData: IapService().isAdFree,
      builder: (context, snapshot) {
        final isAdFree = snapshot.data ?? false;
        
        if (isAdFree) {
          _disposeBanner();
          return const SizedBox.shrink();
        }

        _loadBannerIfNeeded();

        final bannerAd = _bannerAd;
        if (!_isBannerLoaded || bannerAd == null) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: double.infinity,
              child: Center(
                child: SizedBox(
                  width: bannerAd.size.width.toDouble(),
                  height: bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: bannerAd),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
