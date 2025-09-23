import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/station.dart';

class FirebaseSetup {
  static final FirebaseService _firebaseService = FirebaseService();
  
  /// Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // Try to read from Firestore
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection')
          .get();
      
      print('✅ Firebase connection successful!');
      return true;
    } catch (e) {
      print('❌ Firebase connection failed: $e');
      return false;
    }
  }

  /// Populate Firestore with initial radio stations data
  static Future<void> populateInitialData() async {
    try {
      print('🔄 Checking for existing data...');
      
      // Check if data already exists
      final existingStations = await _firebaseService.getAllStations();
      if (existingStations.isNotEmpty) {
        print('✅ Database already has ${existingStations.length} stations');
        return;
      }

      print('🔄 Populating initial data...');
      
      // Comprehensive list of stations from your mock service
      final stations = [
        {
          'name': 'BBC Radio 1',
          'streamUrl': 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one',
          'logoUrl': 'https://cdn-profiles.tunein.com/s15066/images/logod.png',
          'genre': 'Pop',
          'country': 'UK',
          'language': 'English',
          'tags': ['pop', 'music', 'uk', 'bbc'],
          'popularity': 100,
          'contentType': 'radio',
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
          'contentType': 'radio',
        },
        {
          'name': 'Classical FM',
          'streamUrl': 'http://cms.stream.publicradio.org/cms.mp3',
          'logoUrl': 'https://cdn-radiotime-logos.tunein.com/s25650d.png',
          'genre': 'Classical',
          'country': 'USA',
          'language': 'English',
          'tags': ['classical', 'music', 'instrumental'],
          'popularity': 85,
          'contentType': 'radio',
        },
        {
          'name': 'Jazz 24',
          'streamUrl': 'https://live.wostreaming.net/playlist/ppm-jazz24-mp3-128',
          'logoUrl': 'https://cdn-profiles.tunein.com/s34682/images/logod.png',
          'genre': 'Jazz',
          'country': 'USA',
          'language': 'English',
          'tags': ['jazz', 'music', 'smooth'],
          'popularity': 80,
          'contentType': 'radio',
        },
        {
          'name': 'Rock Antenne',
          'streamUrl': 'https://stream.rockantenne.de/rockantenne/stream/mp3',
          'logoUrl': 'https://cdn-profiles.tunein.com/s47660/images/logod.png',
          'genre': 'Rock',
          'country': 'Germany',
          'language': 'German',
          'tags': ['rock', 'metal', 'germany', 'led zeppelin', 'classic rock'],
          'popularity': 90,
          'contentType': 'radio',
        },
        {
          'name': 'The Joe Rogan Experience',
          'streamUrl': 'https://podcast.example.com/joe-rogan/stream',
          'logoUrl': 'https://cdn-profiles.tunein.com/s12346/images/logod.png',
          'genre': 'Talk',
          'country': 'USA',
          'language': 'English',
          'host': 'Joe Rogan',
          'description': 'Long form conversations with interesting people',
          'tags': ['talk', 'comedy', 'interviews', 'joe rogan', 'podcast'],
          'popularity': 98,
          'contentType': 'podcast',
        },
        {
          'name': 'Serial',
          'streamUrl': 'https://podcast.example.com/serial/stream',
          'logoUrl': 'https://cdn-profiles.tunein.com/s12347/images/logod.png',
          'genre': 'True Crime',
          'country': 'USA',
          'language': 'English',
          'host': 'Sarah Koenig',
          'description': 'Investigative journalism podcast',
          'tags': ['true crime', 'investigation', 'serial', 'podcast', 'sarah koenig'],
          'popularity': 92,
          'contentType': 'podcast',
        },
        {
          'name': 'Lofi Hip Hop Stream',
          'streamUrl': 'https://stream.example.com/lofi-hiphop/stream',
          'logoUrl': 'https://cdn-profiles.tunein.com/s12350/images/logod.png',
          'genre': 'Lo-Fi',
          'country': 'Global',
          'language': 'Instrumental',
          'description': '24/7 chill beats to study/relax to',
          'tags': ['lofi', 'hip hop', 'chill', 'study music', 'stream', '24/7'],
          'popularity': 88,
          'contentType': 'stream',
        },
      ];

      // Add stations to Firestore in batches
      final batch = FirebaseFirestore.instance.batch();
      
      for (final stationData in stations) {
        final docRef = FirebaseFirestore.instance
            .collection(FirebaseService.stationsCollection)
            .doc();
        
        batch.set(docRef, {
          ...stationData,
          'isCustom': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      
      print('✅ Successfully added ${stations.length} stations to Firestore!');
      
    } catch (e) {
      print('❌ Error populating initial data: $e');
      throw e;
    }
  }

  /// Complete Firebase setup - test connection and populate data
  static Future<void> completeSetup() async {
    print('🚀 Starting Firebase setup...');
    
    final connectionOk = await testConnection();
    if (!connectionOk) {
      throw Exception('Firebase connection failed');
    }
    
    await populateInitialData();
    
    print('🎉 Firebase setup completed successfully!');
  }
}