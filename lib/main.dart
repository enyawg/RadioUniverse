import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/home_screen_grid.dart';
import 'screens/search_screen.dart';
import 'screens/player_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/settings_screen.dart';
import 'services/favorites_service.dart';
import 'services/carplay_handler.dart';
import 'providers/player_provider.dart';
import 'providers/theme_provider.dart';
import 'services/data_service.dart';
import 'services/subscription_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'config/stripe_config.dart';
import 'services/app_lifecycle_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait (except for iPad/tablets)
  if (!kIsWeb) {
    if (Platform.isIOS || Platform.isAndroid) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    
    // Hide keyboard on startup
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
  
  // Initialize background audio and CarPlay
  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.waynegardner.radioUniverse.audio',
      androidNotificationChannelName: 'Radio Universe',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: true, // Must be true when androidNotificationOngoing is true
    );
  }
  
  // Initialize Firebase with error handling
  try {
    if (!kIsWeb && Platform.isIOS) {
      print('⚠️ Skipping Firebase on iOS for now');
      // Initialize data service with mock data
      await DataService().initialize();
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
      // Initialize data service
      await DataService().initialize();
    }
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    // Fallback to mock data
    await DataService().initialize();
  }
  
  // Initialize services with error handling
  try {
    await FavoritesService().loadFavorites();
    print('✅ FavoritesService initialized');
  } catch (e) {
    print('❌ FavoritesService error: $e');
  }
  
  try {
    await SubscriptionService().initialize();
    print('✅ SubscriptionService initialized with premium: ${SubscriptionService().hasPremiumFeatures}');
    
    // Initialize CarPlay/Android Auto only for premium users
    if (!kIsWeb && SubscriptionService().hasPremiumFeatures) {
      print('✅ Initializing CarPlay for Pro user');
      await AudioService.init(
        builder: () => CarPlayAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.waynegardner.radioUniverse.audio',
          androidNotificationChannelName: 'Radio Universe',
          androidNotificationOngoing: true,
          androidShowNotificationBadge: true,
          androidStopForegroundOnPause: true,
        ),
      );
    } else if (!kIsWeb) {
      print('⚠️ CarPlay requires Pro subscription');
    }
  } catch (e) {
    print('❌ SubscriptionService error: $e');
  }
  
  // Initialize Stripe with test publishable key
  try {
    Stripe.publishableKey = StripeConfig.publishableKeyTest;
    await Stripe.instance.applySettings();
    print('✅ Stripe initialized with test key');
  } catch (e) {
    print('❌ Stripe initialization error: $e');
  }
  
  // Initialize app lifecycle service for background playback control
  AppLifecycleService().initialize();
  print('✅ App lifecycle service initialized');
  
  // Initialize Google Mobile Ads
  try {
    await MobileAds.instance.initialize();
    print('✅ Google Mobile Ads initialized');
  } catch (e) {
    print('❌ Google Mobile Ads initialization error: $e');
  }
  
  runApp(const RadioUniverseApp());
}

class RadioUniverseApp extends StatelessWidget {
  const RadioUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Radio Universe',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey<SearchScreenState> _searchKey = GlobalKey<SearchScreenState>();
  
  @override
  void initState() {
    super.initState();
    // Ensure keyboard is dismissed on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }
  
  late final List<Widget> _screens = [
    // Use grid layout for all platforms now that iOS is working
    const HomeScreenGrid(),
    SearchScreen(key: _searchKey),
    const PlayerScreen(),
    const PlaylistScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Focus search field when Search tab is selected
          if (index == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchKey.currentState?.focusSearchField();
            });
          } else {
            // Dismiss keyboard when leaving search tab
            FocusScope.of(context).unfocus();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 20),
            selectedIcon: Icon(Icons.home, size: 20),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined, size: 20),
            selectedIcon: Icon(Icons.search, size: 20),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_outlined, size: 20),
            selectedIcon: Icon(Icons.radio, size: 20),
            label: 'Playing',
          ),
          NavigationDestination(
            icon: Icon(Icons.playlist_play_outlined, size: 20),
            selectedIcon: Icon(Icons.playlist_play, size: 20),
            label: 'Playlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 20),
            selectedIcon: Icon(Icons.settings, size: 20),
            label: 'Settings',
          ),
        ],
        ),
      ),
    );
  }
}