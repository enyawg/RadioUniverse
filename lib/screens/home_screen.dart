import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/station.dart';
import '../widgets/station_card.dart';
import '../widgets/mini_player.dart';
import '../services/data_service.dart';
import '../providers/player_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  List<Station> _favoriteStations = [];
  List<Station> _recentStations = [];
  List<Station> _popularStations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  void _loadStations() async {
    try {
      final popularStations = await _dataService.getPopularStations();
      // TODO: Load favorites and recent stations from local storage
      
      setState(() {
        _popularStations = popularStations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Radio Universe'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_favoriteStations.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    'Favorites',
                    _favoriteStations,
                    Icons.favorite,
                  ),
                ),
              if (_recentStations.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    'Recently Played',
                    _recentStations,
                    Icons.history,
                  ),
                ),
              SliverToBoxAdapter(
                child: _buildSection(
                  context,
                  'Popular Stations',
                  _popularStations,
                  Icons.trending_up,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Station> stations,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StationCard(
                  station: stations[index],
                  onTap: () => _playStation(stations[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
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