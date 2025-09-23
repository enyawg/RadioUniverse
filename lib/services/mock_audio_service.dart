import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/station.dart';
import '../utils/player_state.dart';

class MockRadioPlayerService {
  static final MockRadioPlayerService _instance = MockRadioPlayerService._internal();
  factory MockRadioPlayerService() => _instance;
  MockRadioPlayerService._internal();

  // Stream controllers
  final _stationController = BehaviorSubject<Station?>();
  final _playerStateController = BehaviorSubject<PlayerState>.seeded(PlayerState.stopped);
  final _volumeController = BehaviorSubject<double>.seeded(0.7);
  final _errorController = StreamController<String>.broadcast();
  final _metadataController = BehaviorSubject<String?>();

  // Getters for streams
  Stream<Station?> get stationStream => _stationController.stream;
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<String?> get metadataStream => _metadataController.stream;

  // Current values
  Station? get currentStation => _stationController.valueOrNull;
  PlayerState get playerState => _playerStateController.value;
  double get volume => _volumeController.value;

  bool get isPlaying => playerState == PlayerState.playing;
  bool get isLoading => playerState == PlayerState.loading;
  bool get hasStopped => playerState == PlayerState.stopped;

  // Mock metadata examples
  final List<String> _mockMetadata = [
    'Now Playing: Radio Universe Theme',
    'The Beatles - Hey Jude',
    'Queen - Bohemian Rhapsody',
    'Led Zeppelin - Stairway to Heaven',
    'Pink Floyd - Wish You Were Here',
    'The Rolling Stones - Paint It Black',
  ];
  int _metadataIndex = 0;
  Timer? _metadataTimer;

  Future<void> initialize() async {
    print('Mock Audio Service initialized');
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> playStation(Station station) async {
    try {
      print('Mock: Playing station ${station.name}');
      _playerStateController.add(PlayerState.loading);
      _stationController.add(station);

      // Simulate loading time
      await Future.delayed(const Duration(seconds: 2));

      _playerStateController.add(PlayerState.playing);
      
      // Start mock metadata updates
      _startMockMetadata();
      
    } catch (e) {
      _playerStateController.add(PlayerState.error);
      _errorController.add('Mock error: Failed to play station');
    }
  }

  Future<void> play() async {
    if (currentStation == null) return;
    
    print('Mock: Play');
    await Future.delayed(const Duration(milliseconds: 300));
    _playerStateController.add(PlayerState.playing);
    _startMockMetadata();
  }

  Future<void> pause() async {
    print('Mock: Pause');
    await Future.delayed(const Duration(milliseconds: 300));
    _playerStateController.add(PlayerState.paused);
    _stopMockMetadata();
  }

  Future<void> stop() async {
    print('Mock: Stop');
    await Future.delayed(const Duration(milliseconds: 300));
    _playerStateController.add(PlayerState.stopped);
    _stopMockMetadata();
  }

  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    print('Mock: Set volume to ${(clampedVolume * 100).round()}%');
    _volumeController.add(clampedVolume);
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  void _startMockMetadata() {
    _stopMockMetadata();
    _updateMetadata();
    _metadataTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateMetadata();
    });
  }

  void _stopMockMetadata() {
    _metadataTimer?.cancel();
    _metadataTimer = null;
  }

  void _updateMetadata() {
    _metadataController.add(_mockMetadata[_metadataIndex]);
    _metadataIndex = (_metadataIndex + 1) % _mockMetadata.length;
  }

  void dispose() {
    _stopMockMetadata();
    _stationController.close();
    _playerStateController.close();
    _volumeController.close();
    _errorController.close();
    _metadataController.close();
  }
}