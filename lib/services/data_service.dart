import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station.dart';
import 'firebase_service.dart';
import 'mock_firebase_service.dart';
import 'radio_browser_api.dart';
import 'subscription_service.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  late final dynamic _service;
  RadioBrowserAPI? _radioAPI;
  bool _isInitialized = false;
  final SubscriptionService _subscriptionService = SubscriptionService();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize Radio Browser API
    _radioAPI = RadioBrowserAPI();
    _radioAPI!.initialize();
    _isInitialized = true;
    
    // Initialize subscription service
    await _subscriptionService.initialize();
    print('DataService initialized with premium: ${_subscriptionService.hasPremiumFeatures}');
    
    // Always use MockFirebaseService for curated stations (22 stations for free users)
    _service = MockFirebaseService();
    print('Using Mock Firebase Service for curated stations + Radio Browser API for premium');
    print('Premium users will get ${_subscriptionService.hasPremiumFeatures ? "35,000+ stations via API" : "22 curated stations only"}');
  }

  /// Check if user has premium features
  bool get hasPremiumFeatures => _subscriptionService.hasPremiumFeatures;

  Future<List<Station>> getAllStations() async {
    print('getAllStations called with hasPremiumFeatures: $hasPremiumFeatures');
    
    if (!hasPremiumFeatures) {
      // Free users get curated mock stations only
      print('Free user: Returning 22 curated stations');
      final stations = await _service.getAllStations();
      return stations.take(22).toList();
    }
    
    // Premium users get real API with fallback support
    try {
      print('Premium user: Fetching from Radio-Browser API');
      final topStations = await _radioAPI!.getTopStations(limit: 100);
      print('Successfully loaded ${topStations.length} stations from Radio-Browser API');
      return topStations;
    } catch (e) {
      print('❌ Radio-Browser API completely failed: $e');
      print('Returning fallback stations from API instead');
      // Get fallback stations from the API service itself
      return _radioAPI!.getFallbackStations(limit: 22);
    }
  }

  Future<List<Station>> searchStations(String query) async {
    if (!hasPremiumFeatures) {
      // Free users search only in curated stations
      print('Free user: Searching in curated stations for "$query"');
      return await _service.searchStations(query);
    }
    
    // Premium users get real API search
    if (kIsWeb) {
      print('Web platform: Searching mock stations due to CORS limitations');
      return await _service.searchStations(query);
    }
    
    try {
      print('Premium user: Searching Radio-Browser API for "$query"');
      final realResults = await _radioAPI!.searchStations(name: query, limit: 50);
      print('Found ${realResults.length} stations from Radio-Browser API search');
      return realResults;
    } catch (e) {
      print('Radio-Browser search failed, falling back to curated stations: $e');
      return await _service.searchStations(query);
    }
  }

  Future<List<Station>> getStationsByGenre(String genre) async {
    if (!hasPremiumFeatures) {
      return await _service.getStationsByGenre(genre);
    } else {
      try {
        final realStations = await _radioAPI!.searchStations(genre: genre, limit: 100);
        return realStations;
      } catch (e) {
        print('Error getting stations by genre, falling back to curated: $e');
        return await _service.getStationsByGenre(genre);
      }
    }
  }

  Future<List<Station>> getStationsByCountry(String country) async {
    if (!hasPremiumFeatures) {
      return await _service.getStationsByCountry(country);
    } else {
      try {
        final realStations = await _radioAPI!.getStationsByCountry(country, limit: 100);
        return realStations;
      } catch (e) {
        print('Error getting stations by country, falling back to curated: $e');
        return await _service.getStationsByCountry(country);
      }
    }
  }

  Future<List<Station>> getStationsByType(ContentType type) async {
    if (_service is MockFirebaseService) {
      return await _service.getStationsByType(type);
    } else {
      // Firebase service method names may differ
      switch (type) {
        case ContentType.podcast:
          return []; // Implement when needed
        case ContentType.stream:
          return []; // Implement when needed
        case ContentType.radio:
        default:
          return await getAllStations();
      }
    }
  }

  Future<List<Station>> getPopularStations({int limit = 20}) async {
    return await _service.getPopularStations(limit: limit);
  }

  Future<void> addCustomStation(Station station) async {
    if (_service is MockFirebaseService) {
      return await _service.addCustomStation(station);
    } else {
      // Firebase service needs userId - for now use a default
      return await _service.addCustomStation(station, 'default_user');
    }
  }

  Future<List<Station>> getCustomStations() async {
    if (_service is MockFirebaseService) {
      return await _service.getCustomStations();
    } else {
      // Firebase service needs userId - for now use a default
      return await _service.getCustomStations('default_user');
    }
  }

  Future<void> deleteCustomStation(String stationId) async {
    if (_service is MockFirebaseService) {
      return await _service.deleteCustomStation(stationId);
    } else {
      // Firebase service needs userId - for now use a default
      return await _service.deleteCustomStation(stationId, 'default_user');
    }
  }

  // Helper methods
  Future<List<Station>> getPodcasts() async {
    return getStationsByType(ContentType.podcast);
  }

  Future<List<Station>> getRadioStations() async {
    return getStationsByType(ContentType.radio);
  }

  Future<List<Station>> getStreams() async {
    return getStationsByType(ContentType.stream);
  }

  // New API methods for enhanced functionality
  
  /// Search with advanced filters
  Future<List<Station>> searchStationsAdvanced({
    String? name,
    String? country,
    String? language,
    String? genre,
    int limit = 100,
    int offset = 0,
  }) async {
    if (!hasPremiumFeatures) {
      // For free users, just use simple search in curated stations
      return name != null ? await searchStations(name) : [];
    } else {
      try {
        return await _radioAPI!.searchStations(
          name: name,
          country: country,
          language: language,
          genre: genre,
          limit: limit,
          offset: offset,
        );
      } catch (e) {
        print('Error in advanced search: $e');
        return [];
      }
    }
  }

  /// Get available countries for filtering
  Future<List<Map<String, dynamic>>> getAvailableCountries() async {
    if (hasPremiumFeatures) {
      try {
        return await _radioAPI!.getCountries();
      } catch (e) {
        print('Error getting countries: $e');
        return [];
      }
    }
    return [];
  }

  /// Get available genres for filtering
  Future<List<Map<String, dynamic>>> getAvailableGenres() async {
    if (hasPremiumFeatures) {
      try {
        return await _radioAPI!.getGenres();
      } catch (e) {
        print('Error getting genres: $e');
        return [];
      }
    }
    return [];
  }

  /// Test if a station URL is working
  Future<bool> testStationUrl(String url) async {
    if (hasPremiumFeatures) {
      try {
        return await _radioAPI!.testStationUrl(url);
      } catch (e) {
        print('Error testing station URL: $e');
        return false;
      }
    }
    return false;
  }

  /// Get station count info
  String getStationCountInfo() {
    if (!hasPremiumFeatures) {
      return "22 hand-curated stations (Free tier)";
    } else if (kIsWeb) {
      return "22 curated stations (web version)";
    } else {
      return "35,000+ stations via search (Premium)";
    }
  }
}