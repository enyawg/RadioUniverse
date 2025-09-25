import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../widgets/station_list_tile.dart';
import '../services/data_service.dart';
import '../services/subscription_service.dart';
import '../providers/player_provider.dart';
import 'premium_landing_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

// Made public so main.dart can access focusSearchField method

class SearchScreenState extends State<SearchScreen> {
  final DataService _dataService = DataService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Station> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void focusSearchField() {
    _searchFocusNode.requestFocus();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _dataService.searchStations(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching stations: $e');
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                child: Image.asset(
                  'lib/assets/images/ru-logo2.png',
                  height: 35,
                  width: 35,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search stations, artists',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _performSearch,
                  autofocus: false,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchController.text.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No stations found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for a different term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return StationListTile(
          station: _searchResults[index],
          onTap: () => _playStation(_searchResults[index]),
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    final genres = ['Rock', 'Pop', 'Jazz', 'Classical', 'Hip Hop', 'Country'];
    final countries = ['USA', 'UK', 'Canada', 'Australia', 'Germany', 'France'];
    final podcasts = ['Joe Rogan', 'Benny Johnson', 'Ben Shapiro', 'Serial', 'TED'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Premium Status Banner
        Consumer<SubscriptionService>(
          builder: (context, subscriptionService, child) {
            if (!subscriptionService.hasPremiumFeatures) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Limited Search',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Searching 22 curated stations. Upgrade for 35,000+ stations.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PremiumLandingScreen(),
                          ),
                        );
                      },
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        
        // Content Type Filters
        Text(
          'Content Type',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionChip(
                avatar: const Icon(Icons.radio, size: 18),
                label: const Text('Radio'),
                onPressed: () {
                  _searchController.text = 'radio';
                  _performSearch('radio');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionChip(
                avatar: const Icon(Icons.mic, size: 18),
                label: const Text('Podcasts'),
                onPressed: () {
                  _searchController.text = 'podcast';
                  _performSearch('podcast');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionChip(
                avatar: const Icon(Icons.stream, size: 18),
                label: const Text('Streams'),
                onPressed: () {
                  _searchController.text = 'stream';
                  _performSearch('stream');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Popular Podcasters',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: podcasts.map((podcast) {
            return ActionChip(
              label: Text(podcast),
              onPressed: () {
                _searchController.text = podcast;
                _performSearch(podcast);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Browse by Genre',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres.map((genre) {
            return ActionChip(
              label: Text(genre),
              onPressed: () {
                _searchController.text = genre;
                _performSearch(genre);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Browse by Country',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: countries.map((country) {
            return ActionChip(
              label: Text(country),
              onPressed: () {
                _searchController.text = country;
                _performSearch(country);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.add_circle_outline),
          title: const Text('Add Custom Stream URL'),
          subtitle: const Text('Add your own radio stream'),
          onTap: _showAddStreamDialog,
        ),
      ],
    );
  }

  void _showAddStreamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Stream'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Station Name',
                hintText: 'My Favorite Station',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Stream URL',
                hintText: 'https://stream.example.com/radio.mp3',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Add custom stream
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Custom stream added')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _playStation(Station station) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.playStation(station);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing ${station.name}')),
    );
  }
}