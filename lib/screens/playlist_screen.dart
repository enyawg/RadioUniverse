import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/station.dart';
import '../services/favorites_service.dart';
import '../services/subscription_service.dart';
import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';
import 'premium_landing_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Station> _favorites = [];

  // Responsive grid configuration (same as home screen)
  int get _crossAxisCount {
    if (kIsWeb) return 4; // Web: 4 columns
    if (!kIsWeb && Platform.isIOS) {
      // iOS: 3 columns for iPhone
      return 3;
    }
    return 4; // Android: 4 columns (or fallback)
  }
  
  double get _gridAspectRatio {
    if (kIsWeb) return 0.75; // Web
    if (!kIsWeb && Platform.isIOS) return 0.8; // iPhone: slightly taller cards
    return 0.75; // Android
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    // Listen for favorites changes
    _favoritesService.addListener(_loadFavorites);
  }
  
  @override
  void dispose() {
    _favoritesService.removeListener(_loadFavorites);
    super.dispose();
  }

  void _loadFavorites() {
    setState(() {
      _favorites = _favoritesService.favorites;
    });
  }

  Future<void> _removeFavorite(Station station) async {
    await _favoritesService.removeFavorite(station.id);
    // No need to manually refresh - listener will handle it
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${station.name} from playlist'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Playlist'),
        content: const Text('Are you sure you want to remove all stations from your playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _favoritesService.clearAllFavorites();
      // No need to manually refresh - listener will handle it
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/ru-logo2.png',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'My Playlist',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Consumer<SubscriptionService>(
                        builder: (context, subscriptionService, child) {
                          final maxFavorites = subscriptionService.hasPremiumFeatures ? 20 : 2;
                          return Text(
                            '${_favorites.length}/$maxFavorites',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          );
                        },
                      ),
                      if (_favorites.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _clearAllFavorites,
                          icon: const Icon(Icons.clear_all),
                          tooltip: 'Clear all',
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
          
          // Mini Player
          const Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_favorites.isEmpty) {
      return Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.playlist_add,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Playlist is Empty',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on stations to add them to your playlist',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Up to 20 stations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subscriptionService.hasPremiumFeatures 
                      ? Colors.green 
                      : Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (!subscriptionService.hasPremiumFeatures) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Free tier includes favorites for all stations',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 100), // Space for mini player + nav bar
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount, // Responsive columns
          childAspectRatio: _gridAspectRatio,
          crossAxisSpacing: _crossAxisCount == 3 ? 12 : 8, // More spacing for 3 columns
          mainAxisSpacing: 8,
        ),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final station = _favorites[index];
          
          return _PlaylistStationCard(
            station: station,
            onTap: () => _playStation(station),
            onRemove: () => _removeFavorite(station),
          );
        },
      ),
    );
  }

  void _playStation(Station station) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.playStation(station);
  }
}

// Playlist Station Card Widget
class _PlaylistStationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlaylistStationCard({
    required this.station,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with remove button
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Station logo
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: station.logoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: station.logoUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildDefaultImage(context),
                          )
                        : _buildDefaultImage(context),
                  ),
                  
                  // Content type badge
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            switch (station.contentType) {
                              ContentType.radio => Icons.radio,
                              ContentType.podcast => Icons.mic,
                              ContentType.stream => Icons.stream,
                            },
                            size: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            station.contentType.name.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Remove button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 12,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Station info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      station.genre ?? station.host ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Image.asset(
          'lib/assets/images/ru-logo2.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}