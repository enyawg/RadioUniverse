import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/station.dart';
import '../services/favorites_service.dart';
import '../services/data_service.dart';
import '../utils/player_state.dart' as app_state;
import 'audio_service.dart' as radio_service;

class CarPlayAudioHandler extends BaseAudioHandler {
  static const String _favoritesId = 'favorites';
  static const String _allStationsId = 'all_stations';
  
  final radio_service.RadioPlayerService _radioService = radio_service.RadioPlayerService();
  final FavoritesService _favoritesService = FavoritesService();
  final DataService _dataService = DataService();
  
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _stationSubscription;
  List<Station> _allStations = [];
  List<Station> _favoriteStations = [];

  CarPlayAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Load stations and favorites
    _allStations = await _dataService.getAllStations();
    _favoriteStations = _favoritesService.favorites;
    
    // Listen to radio service changes
    _playerStateSubscription = _radioService.playerStateStream.listen((state) {
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (state == app_state.PlayerState.playing) 
            MediaControl.pause 
          else 
            MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _mapPlayerState(state),
        playing: state == app_state.PlayerState.playing,
      ));
    });

    _stationSubscription = _radioService.stationStream.listen((station) {
      if (station != null) {
        mediaItem.add(_createMediaItem(station));
      }
    });

    // Set up the CarPlay browser structure
    _setupCarPlayBrowser();
  }

  AudioProcessingState _mapPlayerState(app_state.PlayerState state) {
    switch (state) {
      case app_state.PlayerState.loading:
        return AudioProcessingState.loading;
      case app_state.PlayerState.playing:
        return AudioProcessingState.ready;
      case app_state.PlayerState.paused:
        return AudioProcessingState.ready;
      case app_state.PlayerState.stopped:
        return AudioProcessingState.idle;
      case app_state.PlayerState.error:
        return AudioProcessingState.error;
    }
  }

  void _setupCarPlayBrowser() {
    // Create the media library structure for CarPlay
    final favoriteItems = _favoriteStations.map(_createMediaItem).toList();
    final allStationItems = _allStations.take(50).map(_createMediaItem).toList(); // Limit for performance
    
    // Create folders for CarPlay navigation
    final favoritesFolder = MediaItem(
      id: _favoritesId,
      title: 'My Playlist',
      displaySubtitle: '${_favoriteStations.length} stations',
      playable: false,
    );
    
    final allStationsFolder = MediaItem(
      id: _allStationsId,
      title: 'All Stations',
      displaySubtitle: '${_allStations.length} stations',
      playable: false,
    );

    // CarPlay structure is set up through getChildren() method
  }

  MediaItem _createMediaItem(Station station) {
    return MediaItem(
      id: station.id,
      title: station.name,
      album: station.genre ?? 'Radio Universe',
      artist: switch (station.contentType) {
        ContentType.radio => '${station.country ?? 'Radio'} • ${station.frequency ?? 'FM'}',
        ContentType.podcast => station.host ?? 'Podcast',
        ContentType.stream => 'Internet Radio',
      },
      artUri: station.logoUrl != null ? Uri.parse(station.logoUrl!) : null,
      playable: true,
      extras: {
        'streamUrl': station.streamUrl,
        'contentType': station.contentType.name,
        'country': station.country,
        'frequency': station.frequency,
        'callSign': station.callSign,
      },
    );
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    switch (parentMediaId) {
      case AudioService.browsableRootId:
        // Root level - show main folders
        return [
          MediaItem(
            id: _favoritesId,
            title: 'My Playlist',
            displaySubtitle: '${_favoriteStations.length} favorites',
            playable: false,
          ),
          MediaItem(
            id: _allStationsId,
            title: 'All Stations',
            displaySubtitle: 'Browse all stations',
            playable: false,
          ),
        ];
        
      case _favoritesId:
        // Return favorite stations
        return _favoriteStations.map(_createMediaItem).toList();
        
      case _allStationsId:
        // Return all stations (limited for performance)
        return _allStations.take(50).map(_createMediaItem).toList();
        
      default:
        return [];
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    // Find the station and play it
    final station = _allStations.firstWhere((s) => s.id == mediaItem.id);
    await _radioService.playStation(station);
  }

  @override
  Future<void> play() async {
    await _radioService.play();
  }

  @override
  Future<void> pause() async {
    await _radioService.pause();
  }

  @override
  Future<void> stop() async {
    await _radioService.stop();
  }

  @override
  Future<void> skipToNext() async {
    // Get current station index and play next
    final current = _radioService.currentStation;
    if (current != null) {
      final currentIndex = _allStations.indexWhere((s) => s.id == current.id);
      if (currentIndex >= 0 && currentIndex < _allStations.length - 1) {
        await _radioService.playStation(_allStations[currentIndex + 1]);
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // Get current station index and play previous
    final current = _radioService.currentStation;
    if (current != null) {
      final currentIndex = _allStations.indexWhere((s) => s.id == current.id);
      if (currentIndex > 0) {
        await _radioService.playStation(_allStations[currentIndex - 1]);
      }
    }
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  void dispose() {
    _playerStateSubscription?.cancel();
    _stationSubscription?.cancel();
  }
}