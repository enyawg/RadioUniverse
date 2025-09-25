import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_service.dart';
import '../models/audio_ad.dart';

/// Manages audio ads for free users
class AudioAdService {
  static final AudioAdService _instance = AudioAdService._internal();
  factory AudioAdService() => _instance;
  AudioAdService._internal();
  
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  // Ad frequency settings
  static const int stationChangesBeforeAd = 7; // Play ad every 7th station change
  static const int minutesBetweenAds = 30; // Minimum 30 minutes between ads
  static const int listeningMinutesBeforeAd = 25; // Interrupt after 25 minutes of continuous listening
  
  // Tracking
  int _stationChangeCount = 0;
  DateTime? _lastAdPlayedTime;
  DateTime? _listeningSessionStart;
  Timer? _periodicAdTimer;
  
  // Ad inventory
  final List<AudioAd> _availableAds = [
    AudioAds.upgradeToProAd,
    // Add more ads as you get them
  ];
  
  /// Initialize the service and load saved state
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _stationChangeCount = prefs.getInt('audio_ad_station_count') ?? 0;
    final lastAdTimestamp = prefs.getInt('audio_ad_last_played');
    if (lastAdTimestamp != null) {
      _lastAdPlayedTime = DateTime.fromMillisecondsSinceEpoch(lastAdTimestamp);
    }
  }
  
  /// Check if we should play an ad before the next station
  Future<bool> shouldPlayAd() async {
    // No ads for premium users
    if (_subscriptionService.hasPremiumFeatures) {
      return false;
    }
    
    // Increment station change count
    _stationChangeCount++;
    await _saveState();
    
    // Check if it's time for an ad
    if (_stationChangeCount >= stationChangesBeforeAd) {
      // Also check time-based limit
      if (_lastAdPlayedTime == null || 
          DateTime.now().difference(_lastAdPlayedTime!).inMinutes >= minutesBetweenAds) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Start tracking listening session for periodic ads
  void startListeningSession() {
    if (_subscriptionService.hasPremiumFeatures) return;
    
    _listeningSessionStart = DateTime.now();
    _schedulePeriodicAd();
  }
  
  /// Stop tracking listening session
  void stopListeningSession() {
    _periodicAdTimer?.cancel();
    _periodicAdTimer = null;
    _listeningSessionStart = null;
  }
  
  /// Schedule a periodic ad interruption
  void _schedulePeriodicAd() {
    _periodicAdTimer?.cancel();
    
    _periodicAdTimer = Timer(Duration(minutes: listeningMinutesBeforeAd), () {
      // This will trigger the ad callback
      _onPeriodicAdTime();
    });
  }
  
  /// Called when it's time for a periodic ad
  void _onPeriodicAdTime() {
    if (onPeriodicAdRequired != null) {
      onPeriodicAdRequired!();
    }
    // Reschedule for next ad
    _schedulePeriodicAd();
  }
  
  /// Set callback for periodic ads
  void Function()? onPeriodicAdRequired;
  
  /// Get the next audio ad to play
  AudioAd getAdToPlay() {
    // Rotate through available ads or use weighted selection
    if (_availableAds.isEmpty) {
      return AudioAds.upgradeToProAd;
    }
    
    // For now, simple rotation
    // Later: Add logic for sponsor ads, targeting, etc.
    final random = Random();
    return _availableAds[random.nextInt(_availableAds.length)];
  }
  
  /// Mark that an ad was played
  Future<void> markAdPlayed() async {
    _stationChangeCount = 0;
    _lastAdPlayedTime = DateTime.now();
    await _saveState();
  }
  
  /// Save state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('audio_ad_station_count', _stationChangeCount);
    if (_lastAdPlayedTime != null) {
      await prefs.setInt('audio_ad_last_played', _lastAdPlayedTime!.millisecondsSinceEpoch);
    }
  }
  
  /// Reset ad tracking (useful for testing)
  Future<void> resetTracking() async {
    _stationChangeCount = 0;
    _lastAdPlayedTime = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('audio_ad_station_count');
    await prefs.remove('audio_ad_last_played');
  }
  
  /// Get debug info
  String getDebugInfo() {
    return '''
Audio Ad Service Debug Info:
- Station changes: $_stationChangeCount/$stationChangesBeforeAd
- Last ad played: ${_lastAdPlayedTime?.toString() ?? 'Never'}
- Minutes since last ad: ${_lastAdPlayedTime != null ? DateTime.now().difference(_lastAdPlayedTime!).inMinutes : 'N/A'}
- Should play ad: ${_stationChangeCount >= stationChangesBeforeAd}
''';
  }
}