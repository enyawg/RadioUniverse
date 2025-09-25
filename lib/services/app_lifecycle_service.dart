import 'package:flutter/material.dart';
import 'subscription_service.dart';
import 'audio_service.dart';

/// Manages app lifecycle and controls background playback based on subscription
class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();
  
  final SubscriptionService _subscriptionService = SubscriptionService();
  final RadioPlayerService _audioService = RadioPlayerService();
  
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }
  
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // For free users, pause when app goes to background
    if (!_subscriptionService.hasPremiumFeatures) {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.detached:
          // Pause playback for free users when app is not in foreground
          if (_audioService.isPlaying) {
            print('🚫 Pausing playback - background play requires Pro subscription');
            _audioService.pause();
          }
          break;
        case AppLifecycleState.resumed:
          // App is back in foreground, user can manually resume if desired
          break;
      }
    }
    // Pro users can continue playing in background
  }
}