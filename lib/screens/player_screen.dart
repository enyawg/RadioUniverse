import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/station.dart';
import '../providers/player_provider.dart';
import '../services/favorites_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final currentStation = playerProvider.currentStation;
        
        if (currentStation == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.radio,
                    size: 120,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Station Playing',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Browse Stations'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(playerProvider),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 80.0),
                      child: Column(
                        children: [
                          _buildStationArtwork(currentStation),
                          const SizedBox(height: 24),
                          _buildStationInfo(currentStation, playerProvider),
                          const SizedBox(height: 24),
                          _buildPlaybackControls(playerProvider),
                          const SizedBox(height: 16),
                          _buildVolumeControl(playerProvider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(PlayerProvider playerProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              // Handle minimize - go back to home
              DefaultTabController.of(context)?.animateTo(0);
            },
          ),
          Text(
            'Now Playing',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(playerProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStationArtwork(Station station) {
    // Make artwork responsive to screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final artworkSize = (screenWidth * 0.65).clamp(200.0, 280.0);
    
    return Hero(
      tag: 'station-${station.id}',
      child: Container(
        width: artworkSize,
        height: artworkSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: station.logoUrl != null
              ? CachedNetworkImage(
                  imageUrl: station.logoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildDefaultArtwork(),
                )
              : _buildDefaultArtwork(),
        ),
      ),
    );
  }

  Widget _buildDefaultArtwork() {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Image.asset(
          'lib/assets/images/ru-logo2.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildStationInfo(Station station, PlayerProvider playerProvider) {
    return Column(
      children: [
        Text(
          station.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (playerProvider.currentMetadata != null)
          Text(
            playerProvider.currentMetadata!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        else if (station.genre != null)
          Text(
            station.genre!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        if (playerProvider.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Connection Error',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaybackControls(PlayerProvider playerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            _favoritesService.isFavorite(playerProvider.currentStation!.id) 
                ? Icons.favorite 
                : Icons.favorite_border,
            color: _favoritesService.isFavorite(playerProvider.currentStation!.id) 
                ? Colors.red 
                : null,
          ),
          iconSize: 32,
          onPressed: () async {
            final station = playerProvider.currentStation!;
            final wasAdded = await _favoritesService.toggleFavorite(station);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    wasAdded 
                        ? 'Added ${station.name} to playlist'
                        : 'Removed ${station.name} from playlist',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        const SizedBox(width: 24),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: playerProvider.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,
                  ),
                  iconSize: 72,
                  color: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    if (playerProvider.hasError) {
                      playerProvider.playStation(playerProvider.currentStation!);
                    } else {
                      playerProvider.togglePlayPause();
                    }
                  },
                ),
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.share),
          iconSize: 32,
          onPressed: () {
            // TODO: Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Share ${playerProvider.currentStation?.name}'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVolumeControl(PlayerProvider playerProvider) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.volume_down,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            Expanded(
              child: Slider(
                value: playerProvider.volume,
                onChanged: (value) {
                  playerProvider.setVolume(value);
                },
              ),
            ),
            Icon(
              Icons.volume_up,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
        Text(
          '${(playerProvider.volume * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showOptionsMenu(PlayerProvider playerProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Sleep Timer'),
            onTap: () {
              Navigator.pop(context);
              _showSleepTimerDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Station Info'),
            onTap: () {
              Navigator.pop(context);
              _showStationInfo(playerProvider.currentStation!);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Report Issue'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report sent')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('15 minutes'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sleep timer set for 15 minutes')),
                );
              },
            ),
            ListTile(
              title: const Text('30 minutes'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sleep timer set for 30 minutes')),
                );
              },
            ),
            ListTile(
              title: const Text('1 hour'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sleep timer set for 1 hour')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStationInfo(Station station) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(station.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (station.genre != null) Text('Genre: ${station.genre}'),
            if (station.country != null) Text('Country: ${station.country}'),
            if (station.frequency != null) Text('Frequency: ${station.frequency}'),
            const SizedBox(height: 8),
            Text(
              'Stream URL:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              station.streamUrl,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}