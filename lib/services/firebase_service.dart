import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String stationsCollection = 'stations';
  static const String usersCollection = 'users';
  static const String customStationsCollection = 'customStations';

  // Station operations
  Future<List<Station>> getAllStations() async {
    try {
      final snapshot = await _firestore
          .collection(stationsCollection)
          .orderBy('popularity', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) => Station.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching stations: $e');
      return [];
    }
  }

  Future<List<Station>> searchStations(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      
      // Search by name
      final nameSnapshot = await _firestore
          .collection(stationsCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      // Search by genre
      final genreSnapshot = await _firestore
          .collection(stationsCollection)
          .where('genre', isEqualTo: query)
          .limit(20)
          .get();

      // Search by country
      final countrySnapshot = await _firestore
          .collection(stationsCollection)
          .where('country', isEqualTo: query)
          .limit(20)
          .get();

      // Combine and deduplicate results
      final allDocs = {
        ...nameSnapshot.docs,
        ...genreSnapshot.docs,
        ...countrySnapshot.docs,
      };

      return allDocs.map((doc) => Station.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error searching stations: $e');
      return [];
    }
  }

  Future<List<Station>> getStationsByGenre(String genre) async {
    try {
      final snapshot = await _firestore
          .collection(stationsCollection)
          .where('genre', isEqualTo: genre)
          .orderBy('popularity', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => Station.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching stations by genre: $e');
      return [];
    }
  }

  Future<List<Station>> getStationsByCountry(String country) async {
    try {
      final snapshot = await _firestore
          .collection(stationsCollection)
          .where('country', isEqualTo: country)
          .orderBy('popularity', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => Station.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching stations by country: $e');
      return [];
    }
  }

  Future<List<Station>> getPopularStations({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(stationsCollection)
          .orderBy('popularity', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Station.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching popular stations: $e');
      return [];
    }
  }

  // Custom station operations
  Future<void> addCustomStation(Station station, String userId) async {
    try {
      await _firestore
          .collection(customStationsCollection)
          .doc(userId)
          .collection('stations')
          .add(station.toFirestore());
    } catch (e) {
      print('Error adding custom station: $e');
      throw e;
    }
  }

  Future<List<Station>> getCustomStations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(customStationsCollection)
          .doc(userId)
          .collection('stations')
          .get();

      return snapshot.docs.map((doc) => Station.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching custom stations: $e');
      return [];
    }
  }

  Future<void> deleteCustomStation(String stationId, String userId) async {
    try {
      await _firestore
          .collection(customStationsCollection)
          .doc(userId)
          .collection('stations')
          .doc(stationId)
          .delete();
    } catch (e) {
      print('Error deleting custom station: $e');
      throw e;
    }
  }

  // Favorites operations (stored locally for now)
  Future<void> toggleFavorite(String stationId, String userId) async {
    // TODO: Implement when authentication is added
    // For now, this will be handled locally
  }

  // Recently played operations (stored locally for now)
  Future<void> addToRecentlyPlayed(Station station, String userId) async {
    // TODO: Implement when authentication is added
    // For now, this will be handled locally
  }

  // Sample data creation (for testing)
  Future<void> createSampleStations() async {
    final sampleStations = [
      {
        'name': 'BBC Radio 1',
        'streamUrl': 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one',
        'logoUrl': 'https://cdn-profiles.tunein.com/s15066/images/logod.png',
        'genre': 'Pop',
        'country': 'UK',
        'language': 'English',
        'tags': ['pop', 'music', 'uk', 'bbc'],
        'popularity': 100,
      },
      {
        'name': 'NPR',
        'streamUrl': 'https://npr-ice.streamguys1.com/live.mp3',
        'logoUrl': 'https://cdn-profiles.tunein.com/s24941/images/logod.png',
        'genre': 'News',
        'country': 'USA',
        'language': 'English',
        'tags': ['news', 'talk', 'usa', 'npr'],
        'popularity': 95,
      },
      {
        'name': 'Classical FM',
        'streamUrl': 'https://classicalfm.stream.example.com',
        'genre': 'Classical',
        'country': 'USA',
        'language': 'English',
        'tags': ['classical', 'music', 'instrumental'],
        'popularity': 85,
      },
      {
        'name': 'Jazz 24',
        'streamUrl': 'https://jazz24.stream.example.com',
        'genre': 'Jazz',
        'country': 'USA',
        'language': 'English',
        'tags': ['jazz', 'music', 'smooth'],
        'popularity': 80,
      },
      {
        'name': 'Rock Radio',
        'streamUrl': 'https://rockradio.stream.example.com',
        'genre': 'Rock',
        'country': 'USA',
        'language': 'English',
        'tags': ['rock', 'music', 'alternative'],
        'popularity': 90,
      },
    ];

    final batch = _firestore.batch();
    
    for (final stationData in sampleStations) {
      final docRef = _firestore.collection(stationsCollection).doc();
      batch.set(docRef, {
        ...stationData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    print('Sample stations created successfully');
  }
}