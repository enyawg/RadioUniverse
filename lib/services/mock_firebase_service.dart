import '../models/station.dart';

class MockFirebaseService {
  static final MockFirebaseService _instance = MockFirebaseService._internal();
  factory MockFirebaseService() => _instance;
  MockFirebaseService._internal();

  final List<Station> _mockStations = [
    Station(
      id: '1',
      name: 'BBC Radio 1',
      streamUrl: 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one',
      logoUrl: 'https://sounds.bbci.co.uk/sounds-assets/images/favicon-32x32.png',
      genre: 'Pop',
      country: 'UK',
      tags: ['pop', 'music', 'uk', 'bbc'],
    ),
    Station(
      id: '2',
      name: 'NPR News',
      streamUrl: 'https://npr-ice.streamguys1.com/live.mp3',
      logoUrl: 'https://www.npr.org/favicon.ico',
      genre: 'News',
      country: 'USA',
      tags: ['news', 'talk', 'usa', 'npr'],
    ),
    Station(
      id: '3',
      name: 'Classical KUSC',
      streamUrl: 'https://playerservices.streamtheworld.com/api/livestream-redirect/KUSCMP128.mp3',
      logoUrl: 'https://www.kusc.org/apple-touch-icon.png',
      genre: 'Classical',
      country: 'USA',
      tags: ['classical', 'music', 'instrumental'],
    ),
    Station(
      id: '4',
      name: 'Jazz 24',
      streamUrl: 'https://live.wostreaming.net/direct/ppm-jazz24aac-ibc1',
      logoUrl: 'https://www.jazz24.org/wp-content/uploads/2018/05/jazz24-logo.png',
      genre: 'Jazz',
      country: 'USA',
      tags: ['jazz', 'music', 'smooth'],
    ),
    Station(
      id: '5',
      name: 'KEXP 90.3 Seattle',
      streamUrl: 'https://kexp-mp3.streamguys1.com/kexp320.mp3',
      logoUrl: 'https://www.kexp.org/apple-touch-icon-152x152.png',
      genre: 'Alternative',
      country: 'USA',
      tags: ['indie', 'alternative', 'rock'],
    ),
    Station(
      id: '6',
      name: 'Radio Paradise',
      streamUrl: 'https://stream.radioparadise.com/aac-320',
      logoUrl: 'https://img.radioparadise.com/favicon-32x32.png',
      genre: 'Eclectic',
      country: 'USA',
      tags: ['eclectic', 'rock', 'world'],
    ),
    Station(
      id: '7',
      name: 'SomaFM: Groove Salad',
      streamUrl: 'https://ice2.somafm.com/groovesalad-256-mp3',
      logoUrl: 'https://somafm.com/img3/groovesalad120.png',
      genre: 'Electronic',
      country: 'USA',
      tags: ['electronic', 'ambient', 'chill'],
    ),
    Station(
      id: '8',
      name: 'BBC Radio 2',
      streamUrl: 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_two',
      logoUrl: 'https://sounds.bbci.co.uk/sounds-assets/images/favicon-32x32.png',
      genre: 'Adult Contemporary',
      country: 'UK',
      tags: ['adult contemporary', 'pop', 'uk', 'bbc'],
    ),
    Station(
      id: '9',
      name: 'BBC Radio 4',
      streamUrl: 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm',
      logoUrl: 'https://sounds.bbci.co.uk/sounds-assets/images/favicon-32x32.png',
      genre: 'Talk',
      country: 'UK',
      tags: ['talk', 'news', 'drama', 'uk', 'bbc'],
    ),
    Station(
      id: '10',
      name: 'BBC Radio 6 Music',
      streamUrl: 'https://stream.live.vc.bbcmedia.co.uk/bbc_6music',
      logoUrl: 'https://sounds.bbci.co.uk/sounds-assets/images/favicon-32x32.png',
      genre: 'Alternative',
      country: 'UK',
      tags: ['alternative', 'indie', 'uk', 'bbc'],
    ),
    Station(
      id: '11',
      name: 'KCRW 89.9 FM',
      streamUrl: 'https://kcrw.streamguys1.com/kcrw_192k_mp3_on_air',
      logoUrl: 'https://www.kcrw.com/apple-icon-152x152.png',
      genre: 'Eclectic',
      country: 'USA',
      tags: ['eclectic', 'public radio', 'music', 'news'],
    ),
    Station(
      id: '12',
      name: 'SomaFM: Drone Zone',
      streamUrl: 'https://ice2.somafm.com/dronezone-256-mp3',
      logoUrl: 'https://somafm.com/img3/dronezone120.png',
      genre: 'Ambient',
      country: 'USA',
      tags: ['ambient', 'drone', 'atmospheric', 'electronic'],
    ),
    // Podcasts
    Station(
      id: '13',
      name: 'The Joe Rogan Experience',
      streamUrl: 'https://podcast.example.com/joe-rogan/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12346/images/logod.png',
      genre: 'Talk',
      country: 'USA',
      contentType: ContentType.podcast,
      host: 'Joe Rogan',
      description: 'Long form conversations with interesting people',
      tags: ['talk', 'comedy', 'interviews', 'joe rogan', 'podcast'],
    ),
    Station(
      id: '14',
      name: 'Serial',
      streamUrl: 'https://podcast.example.com/serial/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12347/images/logod.png',
      genre: 'True Crime',
      country: 'USA',
      contentType: ContentType.podcast,
      host: 'Sarah Koenig',
      description: 'Investigative journalism podcast',
      tags: ['true crime', 'investigation', 'serial', 'podcast', 'sarah koenig'],
    ),
    Station(
      id: '15',
      name: 'TED Talks Daily',
      streamUrl: 'https://podcast.example.com/ted-talks/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12348/images/logod.png',
      genre: 'Education',
      country: 'USA',
      contentType: ContentType.podcast,
      host: 'TED',
      description: 'Ideas worth spreading',
      tags: ['education', 'ted', 'talks', 'inspiration', 'podcast'],
    ),
    Station(
      id: '16',
      name: 'Gemischtes Hack',
      streamUrl: 'https://podcast.example.com/gemischtes-hack/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12349/images/logod.png',
      genre: 'Comedy',
      country: 'Germany',
      contentType: ContentType.podcast,
      host: 'Felix Lobrecht & Tommi Schmitt',
      description: 'German comedy podcast',
      tags: ['comedy', 'german', 'felix lobrecht', 'tommi schmitt', 'podcast'],
    ),
    // Live Streams
    Station(
      id: '17',
      name: 'Lofi Hip Hop Stream',
      streamUrl: 'https://stream.example.com/lofi-hiphop/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12350/images/logod.png',
      genre: 'Lo-Fi',
      country: 'Global',
      contentType: ContentType.stream,
      description: '24/7 chill beats to study/relax to',
      tags: ['lofi', 'hip hop', 'chill', 'study music', 'stream', '24/7'],
    ),
    Station(
      id: '18',
      name: 'Nature Sounds Stream',
      streamUrl: 'https://stream.example.com/nature-sounds/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12351/images/logod.png',
      genre: 'Ambient',
      country: 'Global',
      contentType: ContentType.stream,
      description: 'Relaxing nature sounds for meditation',
      tags: ['nature', 'ambient', 'relaxation', 'meditation', 'stream'],
    ),
    Station(
      id: '19',
      name: 'The Benny Johnson Show',
      streamUrl: 'https://podcast.example.com/benny-johnson/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12352/images/logod.png',
      genre: 'Politics',
      country: 'USA',
      contentType: ContentType.podcast,
      host: 'Benny Johnson',
      description: 'Political commentary and news analysis',
      tags: ['politics', 'news', 'conservative', 'benny johnson', 'podcast'],
    ),
    Station(
      id: '20',
      name: 'The Ben Shapiro Show',
      streamUrl: 'https://podcast.example.com/ben-shapiro/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12353/images/logod.png',
      genre: 'Politics',
      country: 'USA',
      contentType: ContentType.podcast,
      host: 'Ben Shapiro',
      description: 'Conservative political commentary',
      tags: ['politics', 'conservative', 'ben shapiro', 'daily wire', 'podcast'],
    ),
    Station(
      id: '21',
      name: 'The Tim Pool Podcast',
      streamUrl: 'https://podcast.example.com/tim-pool/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12354/images/logod.png',
      genre: 'Politics',
      country: 'USA',
      contentType: ContentType.podcast,
      host: 'Tim Pool',
      description: 'Independent political commentary',
      tags: ['politics', 'independent', 'tim pool', 'news', 'podcast'],
    ),
    Station(
      id: '22',
      name: 'Call Her Daddy',
      streamUrl: 'https://podcast.example.com/call-her-daddy/stream',
      logoUrl: 'https://cdn-profiles.tunein.com/s12355/images/logod.png',
      genre: 'Lifestyle',
      country: 'USA',
      contentType: ContentType.podcast,
      host: 'Alex Cooper',
      description: 'Unfiltered conversations about life and relationships',
      tags: ['lifestyle', 'relationships', 'alex cooper', 'spotify', 'podcast'],
    ),
  ];

  Future<List<Station>> getAllStations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockStations);
  }

  Future<List<Station>> searchStations(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    final queryWords = lowercaseQuery.split(' ').where((word) => word.isNotEmpty).toList();
    
    print('🔍 Searching for: "$query" (words: $queryWords)');
    
    final results = _mockStations.where((station) {
      // Create a searchable text combining all station info
      final searchableText = [
        station.name.toLowerCase(),
        station.genre?.toLowerCase() ?? '',
        station.country?.toLowerCase() ?? '',
        ...station.tags.map((tag) => tag.toLowerCase()),
      ].join(' ');
      
      print('   Checking ${station.name}: "$searchableText"');
      
      // Check if all query words are found in the searchable text
      final matches = queryWords.every((word) => searchableText.contains(word));
      if (matches) print('   ✅ MATCH: ${station.name}');
      
      return matches;
    }).toList();
    
    print('🎯 Found ${results.length} results for "$query"');
    return results;
  }

  Future<List<Station>> getStationsByGenre(String genre) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockStations
        .where((station) => station.genre?.toLowerCase() == genre.toLowerCase())
        .toList();
  }

  Future<List<Station>> getStationsByCountry(String country) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockStations
        .where((station) => station.country?.toLowerCase() == country.toLowerCase())
        .toList();
  }

  Future<List<Station>> getPopularStations({int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockStations.take(limit).toList();
  }

  Future<void> addCustomStation(Station station) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockStations.add(station);
  }

  Future<List<Station>> getCustomStations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockStations.where((station) => station.isCustom).toList();
  }

  Future<void> deleteCustomStation(String stationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockStations.removeWhere((station) => station.id == stationId);
  }

  Future<List<Station>> getStationsByType(ContentType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockStations
        .where((station) => station.contentType == type)
        .toList();
  }

  Future<List<Station>> getPodcasts() async {
    return getStationsByType(ContentType.podcast);
  }

  Future<List<Station>> getRadioStations() async {
    return getStationsByType(ContentType.radio);
  }

  Future<List<Station>> getStreams() async {
    return getStationsByType(ContentType.stream);
  }

  void printAllStations() {
    print('📻 All available content (${_mockStations.length} items):');
    for (final station in _mockStations) {
      final typeIcon = switch (station.contentType) {
        ContentType.radio => '📻',
        ContentType.podcast => '🎙️',
        ContentType.stream => '🌊',
      };
      print('   $typeIcon ${station.name} (${station.country}) - ${station.contentType.name} - Tags: ${station.tags}');
    }
  }
}