import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/station.dart';
import '../utils/player_state.dart' as app_state;
import 'subscription_service.dart';
import 'audio_ad_service.dart';

class RadioPlayerService {
  static final RadioPlayerService _instance = RadioPlayerService._internal();
  factory RadioPlayerService() => _instance;
  RadioPlayerService._internal();

  late AudioPlayer _audioPlayer;
  final AudioAdService _adService = AudioAdService();
  
  // Stream controllers
  final _stationController = BehaviorSubject<Station?>();
  final _playerStateController = BehaviorSubject<app_state.PlayerState>.seeded(app_state.PlayerState.stopped);
  final _volumeController = BehaviorSubject<double>.seeded(0.7);
  final _errorController = StreamController<String>.broadcast();

  // Getters for streams
  Stream<Station?> get stationStream => _stationController.stream;
  Stream<app_state.PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Current values
  Station? get currentStation => _stationController.valueOrNull;
  app_state.PlayerState get playerState => _playerStateController.value;
  double get volume => _volumeController.value;

  bool get isPlaying => playerState == app_state.PlayerState.playing;
  bool get isLoading => playerState == app_state.PlayerState.loading;
  bool get hasStopped => playerState == app_state.PlayerState.stopped;

  Future<void> initialize() async {
    _audioPlayer = AudioPlayer();
    await _adService.initialize();
    
    // Set up periodic ad callback
    _adService.onPeriodicAdRequired = () async {
      await _playPeriodicAd();
    };
    
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          _playerStateController.add(app_state.PlayerState.stopped);
          break;
        case ProcessingState.loading:
        case ProcessingState.buffering:
          _playerStateController.add(app_state.PlayerState.loading);
          break;
        case ProcessingState.ready:
          if (state.playing) {
            _playerStateController.add(app_state.PlayerState.playing);
          } else {
            _playerStateController.add(app_state.PlayerState.paused);
          }
          break;
        case ProcessingState.completed:
          _playerStateController.add(app_state.PlayerState.stopped);
          break;
      }
    });

    // Listen to errors
    _audioPlayer.positionStream.handleError((error) {
      _playerStateController.add(app_state.PlayerState.error);
      _errorController.add(error.toString());
    });

    // Set initial volume
    await _audioPlayer.setVolume(volume);
  }

  Future<void> playStation(Station station) async {
    try {
      _playerStateController.add(app_state.PlayerState.loading);
      
      // Check if we should play an ad first
      if (await _adService.shouldPlayAd()) {
        await _playStationChangeAd();
      }
      
      _stationController.add(station);

      // Stop current playback if any
      await stop();
      
      // Start tracking listening session for periodic ads
      _adService.startListeningSession();

      // Set the audio source with enhanced metadata
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(station.streamUrl),
          tag: MediaItem(
            id: station.id,
            title: station.name,
            album: station.genre ?? 'Radio Universe',
            artist: switch (station.contentType) {
              ContentType.radio => '${station.country ?? 'Radio'} • ${station.frequency ?? 'FM'}',
              ContentType.podcast => station.host ?? 'Podcast',
              ContentType.stream => 'Internet Radio',
            },
            artUri: station.logoUrl != null ? Uri.parse(station.logoUrl!) : null,
            duration: null, // Live stream - no duration
            extras: {
              'contentType': station.contentType.name,
              'country': station.country,
              'frequency': station.frequency,
              'callSign': station.callSign,
            },
          ),
        ),
      );

      // Start playing
      await _audioPlayer.play();
      
    } catch (e) {
      _playerStateController.add(app_state.PlayerState.error);
      _errorController.add('Failed to play station: ${e.toString()}');
      print('Error playing station: $e');
    }
  }

  Future<void> play() async {
    if (currentStation == null) return;
    
    try {
      if (_audioPlayer.playerState.processingState == ProcessingState.idle) {
        // Need to set source again
        await playStation(currentStation!);
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      _playerStateController.add(app_state.PlayerState.error);
      _errorController.add('Failed to play: ${e.toString()}');
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _errorController.add('Failed to pause: ${e.toString()}');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _playerStateController.add(app_state.PlayerState.stopped);
      _adService.stopListeningSession();
    } catch (e) {
      _errorController.add('Failed to stop: ${e.toString()}');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      _volumeController.add(clampedVolume);
    } catch (e) {
      _errorController.add('Failed to set volume: ${e.toString()}');
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  // Get stream information (for some streams that provide metadata)
  Stream<String?> get metadataStream {
    return _audioPlayer.icyMetadataStream.map((metadata) => metadata?.info?.title);
  }

  void dispose() {
    _audioPlayer.dispose();
    _stationController.close();
    _playerStateController.close();
    _volumeController.close();
    _errorController.close();
    _adService.stopListeningSession();
  }
  
  // Audio Ad Methods
  
  /// Play ad before station change
  Future<void> _playStationChangeAd() async {
    try {
      final ad = _adService.getAdToPlay();
      _playerStateController.add(app_state.PlayerState.loading);
      
      // Play the ad
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(ad.audioUrl),
          tag: MediaItem(
            id: ad.id,
            title: ad.title,
            album: 'Advertisement',
            artist: 'Radio Universe',
            duration: Duration(seconds: ad.durationSeconds),
          ),
        ),
      );
      
      await _audioPlayer.play();
      
      // Wait for ad to complete
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
      
      await _adService.markAdPlayed();
      
    } catch (e) {
      print('Error playing ad: $e');
      // Don't block station playback if ad fails
    }
  }
  
  /// Play periodic interruption ad
  Future<void> _playPeriodicAd() async {
    if (!isPlaying || currentStation == null) return;
    
    try {
      // Save current position if stream supports it
      final currentStationBackup = currentStation;
      
      // Fade out current station
      await _fadeOut();
      
      // Play ad
      final ad = _adService.getAdToPlay();
      _playerStateController.add(app_state.PlayerState.loading);
      
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(ad.audioUrl),
          tag: MediaItem(
            id: ad.id,
            title: ad.title,
            album: 'Advertisement',
            artist: 'Radio Universe',
            duration: Duration(seconds: ad.durationSeconds),
          ),
        ),
      );
      
      await _audioPlayer.play();
      
      // Wait for ad to complete
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
      
      await _adService.markAdPlayed();
      
      // Resume the station
      if (currentStationBackup != null) {
        await playStation(currentStationBackup);
        await _fadeIn();
      }
      
    } catch (e) {
      print('Error playing periodic ad: $e');
      // Try to resume station if ad fails
      if (currentStation != null) {
        await playStation(currentStation!);
      }
    }
  }
  
  /// Fade out audio smoothly
  Future<void> _fadeOut() async {
    final startVolume = _audioPlayer.volume;
    const steps = 10;
    const duration = Duration(milliseconds: 500);
    
    for (int i = 0; i < steps; i++) {
      await _audioPlayer.setVolume(startVolume * (1 - i / steps));
      await Future.delayed(Duration(milliseconds: duration.inMilliseconds ~/ steps));
    }
  }
  
  /// Fade in audio smoothly
  Future<void> _fadeIn() async {
    const targetVolume = 0.7;
    const steps = 10;
    const duration = Duration(milliseconds: 500);
    
    for (int i = 0; i <= steps; i++) {
      await _audioPlayer.setVolume(targetVolume * (i / steps));
      await Future.delayed(Duration(milliseconds: duration.inMilliseconds ~/ steps));
    }
  }
}

// Audio metadata class for media notifications
class AudioMetadata {
  final String? album;
  final String? title;
  final String? artwork;

  AudioMetadata({
    this.album,
    this.title,
    this.artwork,
  });
}