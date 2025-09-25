import 'dart:io';

/// AdMob configuration for RadioUniverse
class AdMobConfig {
  // Test Ad Unit IDs - Always use these during development
  static const String bannerAdUnitIdTestIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String bannerAdUnitIdTestAndroid = 'ca-app-pub-3940256099942544/6300978111';
  
  // Production Ad Unit IDs
  static const String bannerAdUnitIdProdIOS = 'ca-app-pub-6038481989373307/2570654834'; // RadioUniverse_iOS_Banner_Home
  static const String bannerAdUnitIdProdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'; // TODO: Add Android banner ID when created
  
  // Get the appropriate banner ad unit ID based on platform and mode
  static String get bannerAdUnitId {
    // Always use test ads during development
    // Change this to false when ready for production
    const bool useTestAds = true; // TODO: Set to false before App Store release
    
    if (useTestAds) {
      return Platform.isIOS ? bannerAdUnitIdTestIOS : bannerAdUnitIdTestAndroid;
    } else {
      return Platform.isIOS ? bannerAdUnitIdProdIOS : bannerAdUnitIdProdAndroid;
    }
  }
  
  // Ad placement settings
  static const double bannerBottomPadding = 50.0; // Above mini player
  static const bool showAdsInFreeMode = true;
  static const bool showAdsInPremiumMode = false;
}