import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/station.dart';

class RadioBrowserAPI {
  // Radio-Browser has multiple servers, try alternatives if one fails
  // Updated order based on current availability
  static const List<String> _apiServers = [
    'https://de1.api.radio-browser.info/json',  // Primary - working
    'https://nl1.api.radio-browser.info/json',  // Secondary
    'https://fr1.api.radio-browser.info/json',  // Tertiary
    'https://at1.api.radio-browser.info/json',  // Last resort (DNS issues)
  ];
  static const int _requestTimeout = 30000; // 30 seconds
  
  // Emergency fallback stations with verified working streams
  static const List<Map<String, dynamic>> _fallbackStations = [
    {
      'name': 'BBC Radio 1',
      'url': 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one',
      'homepage': 'https://www.bbc.co.uk/radio1',
      'favicon': 'https://sounds.bbci.co.uk/sounds-assets/images/favicon-32x32.png',
      'tags': 'pop,music,uk,bbc',
      'country': 'United Kingdom',
      'language': 'english'
    },
    {
      'name': 'KEXP 90.3 FM Seattle',
      'url': 'https://kexp.streamguys1.com/kexp160.aac',
      'homepage': 'https://www.kexp.org/',
      'favicon': 'https://www.kexp.org/apple-touch-icon-152x152.png',
      'tags': 'alternative,indie,rock',
      'country': 'United States',
      'language': 'english'
    },
    {
      'name': 'Radio Paradise (Main Mix)',
      'url': 'https://stream.radioparadise.com/aac-320',
      'homepage': 'https://radioparadise.com/',
      'favicon': 'https://img.radioparadise.com/covers/l/B000002UAP.jpg',
      'tags': 'eclectic,rock,alternative',
      'country': 'United States',
      'language': 'english'
    },
    {
      'name': 'SomaFM: Groove Salad',
      'url': 'https://ice1.somafm.com/groovesalad-256-mp3',
      'homepage': 'https://somafm.com/groovesalad/',
      'favicon': 'https://somafm.com/img3/groovesalad120.png',
      'tags': 'ambient,electronic,chillout',
      'country': 'United States',
      'language': 'english'
    },
    {
      'name': 'Classical KUSC',
      'url': 'https://playerservices.streamtheworld.com/api/livestream-redirect/KUSCMP128.mp3',
      'homepage': 'https://www.kusc.org/',
      'favicon': 'https://www.kusc.org/apple-touch-icon.png',
      'tags': 'classical,music,orchestral',
      'country': 'United States',
      'language': 'english'
    }
  ];
  
  static final RadioBrowserAPI _instance = RadioBrowserAPI._internal();
  factory RadioBrowserAPI() => _instance;
  RadioBrowserAPI._internal();

  late final Dio _dio;
  String _currentBaseUrl = _apiServers[0];
  
  /// Get the current API server being used
  String get currentServer {
    // Extract just the server name from URL (e.g., "de1" from "https://de1.api.radio-browser.info/json")
    final match = RegExp(r'https://(\w+)\.api').firstMatch(_currentBaseUrl);
    return match?.group(1)?.toUpperCase() ?? 'Unknown';
  }
  
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: Duration(milliseconds: _requestTimeout),
      receiveTimeout: Duration(milliseconds: _requestTimeout),
      headers: {
        'User-Agent': 'RadioUniverse/1.0.0',
        'Content-Type': 'application/json',
      },
    ));
    
    // Add logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: false, // Large responses
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  /// Search stations by name with automatic server fallback
  Future<List<Station>> searchStations({
    String? name,
    String? country,
    String? language,
    String? genre,
    int limit = 100,
    int offset = 0,
  }) async {
    int attempts = 0;
    Exception? lastError;
    
    while (attempts < _apiServers.length) {
      try {
        final params = <String, dynamic>{
          'limit': limit,
          'offset': offset,
          'hidebroken': 'true',
          'order': 'clickcount',
          'reverse': 'true',
        };

        if (name != null && name.isNotEmpty) {
          params['name'] = name;
        }
        if (country != null && country.isNotEmpty) {
          params['country'] = country;
        }
        if (language != null && language.isNotEmpty) {
          params['language'] = language;
        }
        if (genre != null && genre.isNotEmpty) {
          params['tag'] = genre;
        }

        final response = await _dio.get('/stations/search', queryParameters: params);
        
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final results = data.map((item) => _parseStation(item as Map<String, dynamic>)).toList();
          print('✅ Search found ${results.length} stations from ${_currentBaseUrl}');
          return results;
        } else {
          throw Exception('Failed to load stations: ${response.statusCode}');
        }
      } on DioException catch (e) {
        lastError = Exception('Network error: ${e.message}');
        print('❌ Search failed on ${_currentBaseUrl}: ${e.message}');
        
        if (e.type == DioExceptionType.unknown || 
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          attempts++;
          if (attempts < _apiServers.length) {
            await _tryNextServer();
            print('🔄 Trying next server for search (attempt $attempts/${_apiServers.length})');
            continue;
          }
        }
        throw lastError;
      } catch (e) {
        throw Exception('Error searching stations: $e');
      }
    }
    
    // If all servers fail for search, throw error (let data service handle fallback)
    throw lastError ?? Exception('All Radio-Browser servers failed for search');
  }

  /// Try different API servers if current one fails
  Future<void> _tryNextServer() async {
    final currentIndex = _apiServers.indexOf(_currentBaseUrl);
    final nextIndex = (currentIndex + 1) % _apiServers.length;
    _currentBaseUrl = _apiServers[nextIndex];
    _dio.options.baseUrl = _currentBaseUrl;
    print('Switching to Radio-Browser server: $_currentBaseUrl');
  }

  /// Get top stations by votes/clicks with automatic server fallback
  Future<List<Station>> getTopStations({
    int limit = 100,
    int offset = 0,
  }) async {
    int attempts = 0;
    Exception? lastError;
    
    while (attempts < _apiServers.length) {
      try {
        final params = {
          'limit': limit,
          'offset': offset,
          'hidebroken': 'true',
          'order': 'clickcount',
          'reverse': 'true',
        };

        final response = await _dio.get('/stations/topclick', queryParameters: params);
        
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final stations = data.map((item) => _parseStation(item as Map<String, dynamic>)).toList();
          print('✅ Successfully loaded ${stations.length} stations from ${_currentBaseUrl}');
          return stations;
        } else {
          throw Exception('Failed to load top stations: ${response.statusCode}');
        }
      } on DioException catch (e) {
        lastError = Exception('Network error: ${e.message}');
        print('❌ Server ${_currentBaseUrl} failed: ${e.message}');
        
        if (e.type == DioExceptionType.unknown || 
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          attempts++;
          if (attempts < _apiServers.length) {
            await _tryNextServer();
            print('🔄 Trying next server (attempt $attempts/${_apiServers.length})');
            continue;
          }
        }
        
        // If we've exhausted all servers, fall through to use fallback
      } catch (e) {
        throw Exception('Error getting top stations: $e');
      }
    }
    
    // If all API servers fail, use fallback stations
    print('⚠️ All Radio-Browser servers failed, returning emergency fallback stations');
    return getFallbackStations(limit: limit);
  }
  
  /// Get emergency fallback stations when API is down
  List<Station> getFallbackStations({int limit = 100}) {
    // Expand the fallback list to 22 stations by repeating and modifying
    final expandedStations = <Map<String, dynamic>>[];
    
    // Add original 5 stations
    expandedStations.addAll(_fallbackStations);
    
    // Add variations of existing stations
    expandedStations.addAll([
      {
        'name': 'BBC Radio 2',
        'url': 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_two',
        'homepage': 'https://www.bbc.co.uk/radio2',
        'favicon': 'https://sounds.bbci.co.uk/sounds-assets/images/favicon-32x32.png',
        'tags': 'adult contemporary,music,uk,bbc',
        'country': 'United Kingdom',
        'language': 'english'
      },
      {
        'name': 'BBC Radio 4',
        'url': 'https://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm',
        'homepage': 'https://www.bbc.co.uk/radio4',
        'favicon': 'https://sounds.bbci.co.uk/sounds-assets/images/favicon-32x32.png',
        'tags': 'talk,news,uk,bbc',
        'country': 'United Kingdom',
        'language': 'english'
      },
      {
        'name': 'BBC Radio 6 Music',
        'url': 'https://stream.live.vc.bbcmedia.co.uk/bbc_6music',
        'homepage': 'https://www.bbc.co.uk/6music',
        'favicon': 'https://sounds.bbci.co.uk/sounds-assets/images/favicon-32x32.png',
        'tags': 'alternative,indie,uk,bbc',
        'country': 'United Kingdom',
        'language': 'english'
      },
      {
        'name': 'SomaFM: Drone Zone',
        'url': 'https://ice2.somafm.com/dronezone-256-mp3',
        'homepage': 'https://somafm.com/dronezone/',
        'favicon': 'https://somafm.com/img3/dronezone120.png',
        'tags': 'ambient,drone,atmospheric',
        'country': 'United States',
        'language': 'english'
      },
      {
        'name': 'SomaFM: Indie Pop Rocks',
        'url': 'https://ice2.somafm.com/indiepop-256-mp3',
        'homepage': 'https://somafm.com/indiepop/',
        'favicon': 'https://somafm.com/img3/indiepop120.png',
        'tags': 'indie,pop,rock',
        'country': 'United States',
        'language': 'english'
      },
      {
        'name': 'KCRW 89.9 FM',
        'url': 'https://kcrw.streamguys1.com/kcrw_192k_mp3_on_air',
        'homepage': 'https://www.kcrw.com/',
        'favicon': 'https://www.kcrw.com/apple-icon-152x152.png',
        'tags': 'eclectic,public radio,music',
        'country': 'United States',
        'language': 'english'
      },
      {
        'name': 'Radio Paradise (Rock Mix)',
        'url': 'https://stream.radioparadise.com/rock-320',
        'homepage': 'https://radioparadise.com/',
        'favicon': 'https://img.radioparadise.com/favicon-32x32.png',
        'tags': 'rock,classic rock,indie rock',
        'country': 'United States',
        'language': 'english'
      },
      {
        'name': 'Radio Paradise (Mellow Mix)',
        'url': 'https://stream.radioparadise.com/mellow-320',
        'homepage': 'https://radioparadise.com/',
        'favicon': 'https://img.radioparadise.com/favicon-32x32.png',
        'tags': 'mellow,acoustic,chill',
        'country': 'United States',
        'language': 'english'
      },
      {
        'name': 'NPR News Now',
        'url': 'https://npr-ice.streamguys1.com/live.mp3',
        'homepage': 'https://www.npr.org/',
        'favicon': 'https://www.npr.org/favicon.ico',
        'tags': 'news,talk,public radio',
        'country': 'United States',
        'language': 'english'
      },
      {
        'name': 'WNYC FM',
        'url': 'https://fm939.wnyc.org/wnycfm',
        'homepage': 'https://www.wnyc.org/',
        'favicon': 'https://media.wnyc.org/media/resources/2023/Jul/12/wnyc_square_logo.png',
        'tags': 'news,talk,public radio',
        'country': 'United States',
        'language': 'english'
      },
      {
        'name': 'Jazz24',
        'url': 'https://live.wostreaming.net/direct/ppm-jazz24aac-ibc1',
        'homepage': 'https://www.jazz24.org/',
        'favicon': 'https://www.jazz24.org/wp-content/uploads/2018/05/jazz24-logo.png',
        'tags': 'jazz,smooth jazz,contemporary',
        'country': 'United States',
        'language': 'english'
      },
      {
        'name': 'KCSM Jazz 91',
        'url': 'https://ice5.securenetsystems.net/KCSM2',
        'homepage': 'https://kcsm.org/',
        'favicon': 'https://kcsm.org/favicon.ico',
        'tags': 'jazz,classic jazz,bebop',
        'country': 'United States',
        'language': 'english'
      }
    ]);
    
    final stations = expandedStations.take(limit).map((data) {
      return Station(
        id: data['name'].toString().replaceAll(' ', '_').toLowerCase(),
        name: data['name'],
        streamUrl: data['url'],
        logoUrl: data['favicon'],
        genre: data['tags'].toString().split(',').first,
        country: data['country'],
        tags: data['tags'].toString().split(','),
        contentType: ContentType.radio,
        createdAt: DateTime.now(),
      );
    }).toList();
    
    print('📻 Returning ${stations.length} emergency fallback stations');
    return stations;
  }

  /// Get stations by country
  Future<List<Station>> getStationsByCountry(
    String countryCode, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final params = {
        'limit': limit,
        'offset': offset,
        'hidebroken': 'true',
        'countrycode': countryCode,
        'order': 'clickcount',
        'reverse': 'true',
      };

      final response = await _dio.get('/stations/bycountrycode/$countryCode', queryParameters: params);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => _parseStation(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load stations for country: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error getting stations by country: $e');
    }
  }

  /// Get all available countries
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await _dio.get('/countries');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error getting countries: $e');
    }
  }

  /// Get all available genres/tags
  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final response = await _dio.get('/tags');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load genres: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error getting genres: $e');
    }
  }

  Station _parseStation(Map<String, dynamic> data) {
    // Clean up the station data
    final name = data['name']?.toString().trim() ?? 'Unknown Station';
    final streamUrl = data['url_resolved']?.toString() ?? data['url']?.toString() ?? '';
    final logoUrl = data['favicon']?.toString();
    final country = data['country']?.toString();
    final language = data['language']?.toString();
    final genre = data['tags']?.toString().split(',').first.trim();
    final bitrate = data['bitrate']?.toString();
    final frequency = bitrate != null ? '${bitrate}kbps' : null;
    
    return Station(
      id: data['stationuuid']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      streamUrl: streamUrl,
      logoUrl: logoUrl?.isNotEmpty == true ? logoUrl : null,
      genre: genre?.isNotEmpty == true ? genre : null,
      frequency: frequency,
      country: country,
      language: language,
      tags: data['tags']?.toString().split(',').map((e) => e.trim()).toList() ?? [],
      isCustom: false,
      contentType: ContentType.radio,
      createdAt: DateTime.now(),
    );
  }

  /// Test a station URL to see if it's working
  Future<bool> testStationUrl(String url) async {
    try {
      final response = await _dio.head(url, 
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return response.statusCode != null && response.statusCode! < 400;
    } catch (e) {
      return false;
    }
  }
}