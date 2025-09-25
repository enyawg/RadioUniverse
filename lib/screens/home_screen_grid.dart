import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/station.dart';
import '../widgets/mini_player.dart';
import '../services/data_service.dart';
import '../services/favorites_service.dart';
import '../services/subscription_service.dart';
import '../providers/player_provider.dart';
import '../widgets/ad_banner_widget.dart';

class HomeScreenGrid extends StatefulWidget {
  const HomeScreenGrid({super.key});

  @override
  State<HomeScreenGrid> createState() => _HomeScreenGridState();
}

class _HomeScreenGridState extends State<HomeScreenGrid> {
  final DataService _dataService = DataService();
  final FavoritesService _favoritesService = FavoritesService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Station> _displayedStations = [];
  List<Station> _favoriteStations = [];
  List<Station> _allStations = [];
  bool _isLoading = true;
  int _currentPage = 0;
  
  // Percentage-based responsive grid configuration
  int get _crossAxisCount {
    final screenWidth = MediaQuery.of(context).size.width;
    const stationBlockWidth = 120.0; // Fixed block size
    const spacing = 20.0; // Total horizontal spacing per item (crossAxisSpacing + margins)
    const padding = 32.0; // Screen horizontal padding (16 * 2)
    
    final availableWidth = screenWidth - padding;
    final itemWidth = stationBlockWidth + spacing;
    
    // Calculate how many columns fit, with reasonable min/max limits
    final columns = (availableWidth / itemWidth).floor().clamp(2, 15);
    return columns;
  }
  
  int get _mainAxisCount {
    final columns = _crossAxisCount;
    // Scale rows proportionally - more columns = more rows
    if (columns <= 3) return 5;      // Mobile: 3x5 (15 stations)
    if (columns <= 4) return 5;      // Small tablet: 4x5 (20 stations)
    if (columns <= 6) return 6;      // Medium: 5-6x6 (30-36 stations)
    if (columns <= 8) return 7;      // Large: 7-8x7 (49-56 stations)
    if (columns <= 10) return 8;     // XL: 9-10x8 (72-80 stations)
    return 8;                        // XXL: 11+x8 (88+ stations)
  }
  
  int get _itemsPerPage {
    return _crossAxisCount * _mainAxisCount;
  }
  
  double get _gridAspectRatio {
    // Consistent aspect ratio across all devices for fixed block size
    return 0.75;
  }

  @override
  void initState() {
    super.initState();
    _loadStations();
    // Listen for favorites changes to update heart icons
    _favoritesService.addListener(_onFavoritesChanged);
    // Listen for subscription changes to reload stations
    _subscriptionService.addListener(_onSubscriptionChanged);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stations when screen becomes visible
    _loadStations();
  }
  
  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    _subscriptionService.removeListener(_onSubscriptionChanged);
    super.dispose();
  }
  
  void _onFavoritesChanged() {
    setState(() {
      _favoriteStations = _favoritesService.favorites;
      _updateDisplayedStations();
    });
  }

  void _onSubscriptionChanged() {
    // Reload all stations when subscription status changes
    _loadStations();
  }

  void _loadStations() async {
    try {
      final allStations = await _dataService.getAllStations();
      final favorites = _favoritesService.favorites;
      
      setState(() {
        _allStations = allStations;
        _favoriteStations = favorites;
        _updateDisplayedStations();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateDisplayedStations() {
    // Start with favorites
    List<Station> displayList = List.from(_favoriteStations);
    
    // Add random mix of remaining stations
    final remainingStations = _allStations
        .where((station) => !_favoriteStations.contains(station))
        .toList()
      ..shuffle();
    
    displayList.addAll(remainingStations);
    
    // Get current page items
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, displayList.length);
    
    _displayedStations = displayList.sublist(
      startIndex, 
      endIndex,
    );
  }

  void _nextPage() {
    final maxPage = (_allStations.length / _itemsPerPage).ceil() - 1;
    if (_currentPage < maxPage) {
      setState(() {
        _currentPage++;
        _updateDisplayedStations();
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _updateDisplayedStations();
      });
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
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row with logo, title, and PRO badge all aligned
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo
                          Image.asset(
                            'lib/assets/images/ru-logo2.png',
                            height: 40,
                            width: 40,
                          ),
                          const SizedBox(width: 12),
                          // Title
                          Text(
                            'Radio Universe',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // PRO badge on the right
                          Consumer<SubscriptionService>(
                            builder: (context, subscriptionService, child) {
                              if (subscriptionService.hasPremiumFeatures) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.black,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'PRO',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Station info below
                      Consumer<SubscriptionService>(
                        builder: (context, subscriptionService, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dataService.getStationCountInfo(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: subscriptionService.hasPremiumFeatures 
                                    ? Colors.green 
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                'Grid: ${_crossAxisCount}×${_mainAxisCount} (${_itemsPerPage} stations)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Navigation buttons
                if (!_isLoading && _allStations.length > _itemsPerPage)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          icon: const Icon(Icons.chevron_left),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                        Text(
                          'Swipe for more stations',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        IconButton(
                          onPressed: _currentPage < (_allStations.length / _itemsPerPage).ceil() - 1 
                              ? _nextPage 
                              : null,
                          icon: const Icon(Icons.chevron_right),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Station Grid
                Expanded(
                  child: _buildBody(),
                ),
                
                // Bottom Navigation buttons
                if (!_isLoading && _allStations.length > _itemsPerPage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          icon: const Icon(Icons.chevron_left),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Page ${_currentPage + 1} of ${(_allStations.length / _itemsPerPage).ceil()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        IconButton(
                          onPressed: _currentPage < (_allStations.length / _itemsPerPage).ceil() - 1 
                              ? _nextPage 
                              : null,
                          icon: const Icon(Icons.chevron_right),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Ad Banner for free users (above mini player)
          Positioned(
            bottom: 90, // Above mini player
            left: 0,
            right: 0,
            child: Consumer<SubscriptionService>(
              builder: (context, subscriptionService, child) {
                if (!subscriptionService.hasPremiumFeatures) {
                  return Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Center(
                      child: AdBannerWidget(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_displayedStations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.radio,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No stations available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 100), // Space for mini player + nav bar
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount, // Dynamic responsive columns
          childAspectRatio: _gridAspectRatio,
          crossAxisSpacing: 12, // Consistent spacing for all layouts
          mainAxisSpacing: 12,
        ),
        itemCount: _displayedStations.length,
        itemBuilder: (context, index) {
          final station = _displayedStations[index];
          final isFavorite = _favoriteStations.contains(station);
          
          return _StationGridItem(
            station: station,
            isFavorite: isFavorite,
            onTap: () => _playStation(station),
            onFavoriteToggle: () => _toggleFavorite(station),
          );
        },
      ),
    );
  }

  void _playStation(Station station) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.playStation(station);
  }

  Future<void> _toggleFavorite(Station station) async {
    final wasAdded = await _favoritesService.toggleFavorite(station);
    // No need to manually refresh - listener will handle it
    
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
  }
}

// Station Grid Item Widget
class _StationGridItem extends StatelessWidget {
  final Station station;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _StationGridItem({
    required this.station,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
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
            // Image with favorite badge
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
                  
                  // Heart toggle button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isFavorite 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 12,
                          color: isFavorite 
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
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
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}