import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService extends ChangeNotifier {
  static const String _premiumKey = 'is_premium_user';
  static const String _trialEndKey = 'trial_end_date';
  static const String _subscriptionDateKey = 'subscription_start_date';
  
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isPremium = false;
  DateTime? _trialEndDate;
  DateTime? _subscriptionStartDate;

  /// Get premium status
  bool get isPremium => _isPremium;
  
  /// Get trial status
  bool get isInFreeTrial {
    if (_trialEndDate == null) return false;
    return DateTime.now().isBefore(_trialEndDate!);
  }
  
  /// Get premium or trial status (user has premium features)
  bool get hasPremiumFeatures => _isPremium || isInFreeTrial;
  
  /// Get days remaining in trial
  int get trialDaysRemaining {
    if (_trialEndDate == null) return 0;
    final remaining = _trialEndDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Initialize subscription service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      
      final trialEnd = prefs.getString(_trialEndKey);
      if (trialEnd != null) {
        try {
          _trialEndDate = DateTime.parse(trialEnd);
        } catch (e) {
          print('⚠️ Invalid trial date format, resetting: $e');
          await prefs.remove(_trialEndKey);
          _trialEndDate = null;
        }
      }
      
      final subStart = prefs.getString(_subscriptionDateKey);
      if (subStart != null) {
        try {
          _subscriptionStartDate = DateTime.parse(subStart);
        } catch (e) {
          print('⚠️ Invalid subscription date format, resetting: $e');
          await prefs.remove(_subscriptionDateKey);
          _subscriptionStartDate = null;
        }
      }
      
      // Debug: Show all stored values
      print('📱 Subscription initialized:');
      print('   Premium: $_isPremium (stored: ${prefs.getBool(_premiumKey)})');
      print('   Trial: ${isInFreeTrial} (ends: $_trialEndDate)');
      print('   Has Premium Features: $hasPremiumFeatures');
      
      // Ensure state is saved immediately
      notifyListeners();
    } catch (e) {
      print('❌ Error initializing subscription: $e');
      // Set safe defaults
      _isPremium = false;
      _trialEndDate = null;
      _subscriptionStartDate = null;
    }
  }

  /// Start free trial (7 days)
  Future<void> startFreeTrial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _trialEndDate = DateTime.now().add(const Duration(days: 7));
      
      await prefs.setString(_trialEndKey, _trialEndDate!.toIso8601String());
      
      print('🎉 Free trial started, ends: $_trialEndDate');
      notifyListeners();
    } catch (e) {
      print('❌ Error starting free trial: $e');
    }
  }

  /// Activate premium subscription
  Future<void> activatePremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Set values in memory first
      _isPremium = true;
      _subscriptionStartDate = DateTime.now();
      
      // Save to persistent storage
      final success1 = await prefs.setBool(_premiumKey, true);
      final success2 = await prefs.setString(_subscriptionDateKey, _subscriptionStartDate!.toIso8601String());
      
      // Verify storage
      final stored = prefs.getBool(_premiumKey) ?? false;
      
      print('⭐ Premium activation:');
      print('   setBool success: $success1');
      print('   setString success: $success2');
      print('   Stored value: $stored');
      print('   Memory value: $_isPremium');
      print('   Has Premium Features: $hasPremiumFeatures');
      
      notifyListeners();
    } catch (e) {
      print('❌ Error activating premium: $e');
      rethrow;
    }
  }

  /// Cancel subscription (remove premium status)
  Future<void> cancelSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = false;
      
      await prefs.setBool(_premiumKey, false);
      
      print('💔 Premium canceled');
      notifyListeners();
    } catch (e) {
      print('❌ Error canceling subscription: $e');
    }
  }

  /// Restore purchases (simulate App Store/Play Store restore)
  Future<bool> restorePurchases() async {
    try {
      // TODO: Integrate with actual in-app purchase system
      // This would check with App Store/Play Store for active subscriptions
      
      // For demo purposes, we'll simulate a successful restore
      await activatePremium();
      return true;
    } catch (e) {
      print('❌ Error restoring purchases: $e');
      return false;
    }
  }

  /// Get subscription status text
  String get statusText {
    if (_isPremium) {
      return 'Premium Member';
    } else if (isInFreeTrial) {
      return 'Free Trial (${trialDaysRemaining} days left)';
    } else {
      return 'Free User';
    }
  }

  /// Get subscription benefits text
  List<String> get premiumBenefits {
    return [
      '35,000+ radio stations worldwide',
      'Advanced search and filters',
      'Ad-free listening experience',
      'Premium audio quality',
      'Cloud sync across devices',
      'Priority customer support',
    ];
  }

  /// Get free tier features
  List<String> get freeBenefits {
    return [
      '22 hand-curated stations',
      '20 favorite stations',
      'Basic search functionality',
      'Standard audio quality',
    ];
  }

  /// Debug: Reset all subscription data
  Future<void> resetSubscriptionForDebug() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_premiumKey);
      await prefs.remove(_trialEndKey);
      await prefs.remove(_subscriptionDateKey);
      
      _isPremium = false;
      _trialEndDate = null;
      _subscriptionStartDate = null;
      
      print('🔄 Subscription data reset');
      notifyListeners();
    } catch (e) {
      print('❌ Error resetting subscription: $e');
    }
  }
  
  /// Debug: Force premium for testing (with persistent storage)
  Future<void> forceActivatePremiumForDebug() async {
    print('🔧 DEBUG: Force activating premium...');
    await activatePremium();
    
    // Double-check it worked
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_premiumKey) ?? false;
    print('🔧 DEBUG: Premium forced. Memory: $_isPremium, Storage: $stored, HasFeatures: $hasPremiumFeatures');
  }
  
  /// Debug: Check current storage state
  Future<void> debugPrintStorageState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('🔧 DEBUG: Storage State:');
      print('   Premium Key: ${prefs.getBool(_premiumKey)}');
      print('   Trial End: ${prefs.getString(_trialEndKey)}');
      print('   Sub Start: ${prefs.getString(_subscriptionDateKey)}');
      print('   Memory Premium: $_isPremium');
      print('   Has Premium Features: $hasPremiumFeatures');
    } catch (e) {
      print('❌ Error checking storage: $e');
    }
  }
}