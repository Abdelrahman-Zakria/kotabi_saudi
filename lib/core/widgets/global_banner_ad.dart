import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kotabi_saudi/core/services/ad_service.dart';
import 'package:kotabi_saudi/core/services/iap_service.dart';

class GlobalBannerAd extends StatefulWidget {
  const GlobalBannerAd({super.key});

  @override
  State<GlobalBannerAd> createState() => _GlobalBannerAdState();
}

class _GlobalBannerAdState extends State<GlobalBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (IapService().isAdFree) return;

    _bannerAd = AdService().createBannerAd()
      ?..load().then((_) {
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: IapService().adFreeStatusStream,
      initialData: IapService().isAdFree,
      builder: (context, snapshot) {
        final isAdFree = snapshot.data ?? false;
        if (isAdFree) {
          _bannerAd?.dispose();
          _bannerAd = null;
          return const SizedBox.shrink();
        }

        if (_bannerAd == null && !isAdFree) {
          _loadBanner();
        }

        final bannerAd = _bannerAd;
        return SafeArea(
          top: false,
          child: SizedBox(
            height: AdSize.banner.height.toDouble(),
            width: double.infinity,
            child: Center(
              child: _isLoaded && bannerAd != null
                  ? SizedBox(
                      width: bannerAd.size.width.toDouble(),
                      height: bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: bannerAd),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
