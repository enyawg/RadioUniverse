import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station.dart';

class FavoritesService extends ChangeNotifier {
  static const String _favoritesKey = 'favorite_stations';
  static const int maxFavorites = 20;
  
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  List<Station> _favorites = [];
  
  /// Get all favorite stations
  List<Station> get favorites => List.unmodifiable(_favorites);
  
  /// Check if station is favorited
  bool isFavorite(String stationId) {
    return _favorites.any((station) => station.id == stationId);
  }
  
  /// Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      _favorites = favoritesJson
          .map((jsonStr) => Station.fromJson(jsonDecode(jsonStr)))
          .toList();
      
      print('✅ Loaded ${_favorites.length} favorites');
    } catch (e) {
      print('❌ Error loading favorites: $e');
      _favorites = [];
    }
  }
  
  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites
          .map((station) => jsonEncode(station.toJson()))
          .toList();
      
      await prefs.setStringList(_favoritesKey, favoritesJson);
      print('✅ Saved ${_favorites.length} favorites');
      notifyListeners(); // Notify UI about changes
    } catch (e) {
      print('❌ Error saving favorites: $e');
    }
  }
  
  /// Add station to favorites
  /// Returns true if added, false if already exists or limit reached
  Future<bool> addFavorite(Station station) async {
    if (isFavorite(station.id)) {
      return false; // Already favorited
    }
    
    if (_favorites.length >= maxFavorites) {
      // Remove oldest favorite to make room
      _favorites.removeAt(0);
      print('⚠️ Favorites limit reached, removed oldest');
    }
    
    _favorites.add(station);
    await _saveFavorites();
    print('⭐ Added favorite: ${station.name}');
    return true;
  }
  
  /// Remove station from favorites
  Future<bool> removeFavorite(String stationId) async {
    final index = _favorites.indexWhere((station) => station.id == stationId);
    if (index == -1) {
      return false; // Not found
    }
    
    final removed = _favorites.removeAt(index);
    await _saveFavorites();
    print('💔 Removed favorite: ${removed.name}');
    return true;
  }
  
  /// Toggle favorite status
  Future<bool> toggleFavorite(Station station) async {
    if (isFavorite(station.id)) {
      await removeFavorite(station.id);
      return false; // Removed
    } else {
      await addFavorite(station);
      return true; // Added
    }
  }
  
  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    print('🗑️ Cleared all favorites');
  }
  
  /// Get favorite stations count
  int get favoritesCount => _favorites.length;
  
  /// Check if favorites are full
  bool get isFull => _favorites.length >= maxFavorites;
  
  /// Get remaining slots
  int get remainingSlots => maxFavorites - _favorites.length;
}