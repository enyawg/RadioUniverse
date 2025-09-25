import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../config/admob_config.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final subscriptionService = context.read<SubscriptionService>();
    
    // Only load ads for free users
    if (!subscriptionService.hasPremiumFeatures && AdMobConfig.showAdsInFreeMode) {
      _bannerAd = BannerAd(
        adUnitId: AdMobConfig.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isAdLoaded = true;
            });
            print('✅ Banner ad loaded');
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Banner ad failed to load: $error');
            ad.dispose();
          },
        ),
      );
      _bannerAd!.load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to subscription changes
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        // Hide ads for premium users
        if (subscriptionService.hasPremiumFeatures || !AdMobConfig.showAdsInFreeMode) {
          return const SizedBox.shrink();
        }

        // Show ad if loaded
        if (_isAdLoaded && _bannerAd != null) {
          return Container(
            alignment: Alignment.center,
            height: _bannerAd!.size.height.toDouble(),
            width: _bannerAd!.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          );
        }

        // Show placeholder while loading
        return Container(
          height: 50,
          alignment: Alignment.center,
          child: const Text(
            'Advertisement',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}