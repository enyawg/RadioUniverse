import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/station.dart';
import '../utils/player_state.dart';
import '../services/audio_service.dart';
import '../services/mock_audio_service.dart';

class PlayerProvider extends ChangeNotifier {
  late dynamic _audioService;
  
  PlayerProvider() {
    // For testing: Use real audio service on all platforms
    _audioService = RadioPlayerService();
    print('🎵 Using Real Radio Player Service');
    
    // Note: Uncomment below to use mock service on web
    // if (kIsWeb) {
    //   _audioService = MockRadioPlayerService();
    // } else {
    //   _audioService = RadioPlayerService();
    // }
    _initializePlayer();
  }
  
  // Stream subscriptions
  StreamSubscription<Station?>? _stationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<double>? _volumeSubscription;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<String?>? _metadataSubscription;

  // Current values
  Station? _currentStation;
  PlayerState _playerState = PlayerState.stopped;
  double _volume = 0.7;
  String? _currentMetadata;
  String? _errorMessage;

  // Getters
  Station? get currentStation => _currentStation;
  PlayerState get playerState => _playerState;
  double get volume => _volume;
  String? get currentMetadata => _currentMetadata;
  String? get errorMessage => _errorMessage;

  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isLoading => _playerState == PlayerState.loading;
  bool get isPaused => _playerState == PlayerState.paused;
  bool get hasStopped => _playerState == PlayerState.stopped;
  bool get hasError => _playerState == PlayerState.error;

  Future<void> _initializePlayer() async {
    await _audioService.initialize();
    _subscribeToStreams();
  }

  void _subscribeToStreams() {
    _stationSubscription = _audioService.stationStream.listen((station) {
      _currentStation = station;
      notifyListeners();
    });

    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      _playerState = state;
      if (state != PlayerState.error) {
        _errorMessage = null;
      }
      notifyListeners();
    });

    _volumeSubscription = _audioService.volumeStream.listen((volume) {
      _volume = volume;
      notifyListeners();
    });

    _errorSubscription = _audioService.errorStream.listen((error) {
      _errorMessage = error;
      notifyListeners();
    });

    _metadataSubscription = _audioService.metadataStream.listen((metadata) {
      _currentMetadata = metadata;
      notifyListeners();
    });
  }

  // Player controls
  Future<void> playStation(Station station) async {
    await _audioService.playStation(station);
  }

  Future<void> play() async {
    await _audioService.play();
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> stop() async {
    await _audioService.stop();
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _volumeSubscription?.cancel();
    _errorSubscription?.cancel();
    _metadataSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}