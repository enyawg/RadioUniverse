# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RadioUniverse is a Flutter-based radio streaming application for iOS and Android that allows users to listen to 35,000+ AM/FM/Internet radio stations globally via the Radio-Browser API. The app supports Apple CarPlay and Android Auto integration for in-car listening, with a favorites-only mode toggle and Google AdMob integration for monetization.

## Tech Stack

- **Frontend**: Flutter 3.0+ with Material Design
- **Backend**: Firebase (Auth, Firestore, Analytics) + Radio-Browser API
- **Audio**: just_audio + audio_service for background playback
- **State Management**: Provider pattern + SharedPreferences
- **Platform Integration**: CarPlay (iOS), Android Auto
- **Monetization**: Google AdMob (planned)
- **HTTP Client**: Dio with caching and error handling

## Key Features

1. **Station Discovery & Search**
   - 35,000+ stations via Radio-Browser API
   - Search by station name, country, genre, language
   - Advanced filters and pagination
   - Real-time station availability testing

2. **Dual Station Modes**
   - **Favorites Only**: 20-slot curated favorites
   - **All Stations**: Full 35,000+ worldwide database
   - Settings toggle with persistent storage
   - Seamless mode switching

3. **Stream Management**
   - Add custom radio stream URLs
   - Full CRUD operations via Firebase
   - HTTP client with error handling and fallbacks

4. **Platform Integration**
   - Apple CarPlay support with favorites structure
   - Android Auto support 
   - Background playbook with full system integration
   - Lock screen controls and metadata

5. **User Features**
   - 20-slot favorites system with live sync
   - Heart icon toggles on station cards
   - Responsive grid layout (3x5 iPhone, 4x5 tablets/web)
   - Bi-directional favorites synchronization

6. **Background Playback**
   - Continue playing when app is minimized
   - Enhanced lock screen controls with artwork
   - Notification controls with skip/previous
   - Proper audio session management

7. **Monetization (Planned)**
   - Google AdMob banner ads
   - Ad-free experience in Favorites mode
   - Future premium features planned

8. **No Authentication Required**
   - All features available without sign-in
   - Local storage with SharedPreferences
   - Optional Firebase sync for cross-device access

## Project Structure
```
lib/
├── main.dart                    # App entry point with CarPlay/Audio Service init
├── screens/                     # UI screens
│   ├── home_screen_grid.dart   # Main grid layout (3x5/4x5)
│   ├── search_screen.dart      # Station search with filters
│   ├── player_screen.dart      # Currently playing screen
│   ├── playlist_screen.dart    # 20-slot favorites grid
│   ├── settings_screen.dart    # Settings with station mode toggle
│   └── firebase_setup_screen.dart
├── services/                   # Business logic
│   ├── audio_service.dart      # Audio playback service
│   ├── data_service.dart       # Main data coordinator
│   ├── firebase_service.dart   # Firebase integration
│   ├── mock_firebase_service.dart # Local/mock data
│   ├── radio_browser_api.dart  # 35k+ stations API
│   ├── favorites_service.dart  # 20-slot favorites management
│   └── carplay_handler.dart    # CarPlay/Android Auto
├── models/                     # Data models
│   ├── station.dart           # Station model with ContentType enum
│   └── user_preferences.dart
├── providers/                  # State management
│   └── player_provider.dart   # Audio player state
├── utils/                     # Utilities
│   └── player_state.dart     # Player state enums
├── theme/                   # Theme system
│   └── app_theme.dart      # Dark, Light, Pastel themes
└── assets/images/          # Logo and UI assets
```

## Common Commands

```bash
# Run the app
flutter run

# Run on specific device
flutter run -d iPhone_15_Pro  # iOS simulator
flutter run -d emulator-5554  # Android emulator

# Build for release
flutter build ios --release
flutter build apk --release
flutter build appbundle --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .

# Clean build
flutter clean

# Update dependencies
flutter pub upgrade

# Generate icons
flutter pub run flutter_launcher_icons
```

## Firebase Setup

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase:
```bash
flutterfire configure
```

3. Initialize Firebase in main.dart:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Key Implementation Notes

### Audio Service Setup
- Use `just_audio` for streaming
- Implement `audio_service` for background playback
- Handle audio focus and interruptions
- Implement notification controls

### Station Management
- Store favorites in Firestore
- Cache station logos locally
- Validate stream URLs before playback
- Handle various stream formats (M3U8, MP3, AAC)

### UI/UX Guidelines
- Material Design 3 principles
- Smooth animations with Hero widgets
- Responsive design for tablets
- Dark mode support
- Accessibility features

### Background Playback (iOS)
- Enable background modes in Info.plist
- Configure audio session
- Update Now Playing Info Center
- Handle remote commands

### Background Playback (Android)
- Implement foreground service
- Create media notification
- Handle MediaSession
- Manage wake locks

### CarPlay Integration
- Use platform channels for native integration
- Implement CPListTemplate for stations
- Handle CPNowPlayingTemplate
- Test with CarPlay Simulator

### Android Auto Integration
- Implement MediaBrowserService
- Define Auto-compatible UI
- Handle voice commands
- Test with Desktop Head Unit

## Testing Strategy

1. **Widget Tests**: UI components
2. **Integration Tests**: User flows
3. **Unit Tests**: Services and utilities
4. **Platform Tests**: iOS/Android specific features

## Current Implementation Status

### ✅ **Completed Features**
- **Radio-Browser API Integration**: 35,000+ stations with Dio HTTP client
- **Premium/Subscription System**: Free tier (22 stations) vs Premium (35,000+ stations)
- **API Server Fallback**: Automatic switching between multiple Radio-Browser servers
- **Optimized Station Loading**: 100 top stations for browsing, full access via search
- **Search Functionality**: Premium users search all 35,000+ stations (50 results per query)
- **Background Playbook**: Full system integration with lock screen controls
- **CarPlay/Android Auto**: Complete implementation with favorites structure
- **20-Slot Favorites**: Live bidirectional sync with heart icons
- **Responsive UI**: 3x5 grid (iPhone), 4x5 grid (tablets/web)
- **Theme System**: Dark (default), Light, and Pastel themes with persistence
- **Debug Tools**: Premium activation button for testing in debug mode

### ⚠️ **Known Issues**
- **Station Connection Errors**: Normal with 35,000+ stations database
  - Some stations are temporarily offline, overloaded, or geo-blocked
  - Solution: Simply try another station
  - Future: Could implement stream URL testing before playback

### 🔄 **Recently Fixed (September 23, 2025)**
- ✅ **FIXED**: Premium settings now persist across app restarts with enhanced SharedPreferences handling
- ✅ **FIXED**: Radio-Browser API server fallback system restored with proper server prioritization
- ✅ **FIXED**: Data service routing now properly differentiates free vs premium users
- ✅ **FIXED**: Emergency fallback stations (BBC, KEXP, Radio Paradise, etc.) now accessible
- ✅ **FIXED**: Enhanced error handling and logging throughout the API stack

### 🔄 **Still In Progress**
- **CRITICAL**: Firebase configuration broken after flutterfire reconfigure (temporarily bypassed)

### ⚠️ **Known Issues**
- **Firebase Reconfiguration**: Running `flutterfire configure` broke working Firebase setup
- **Bundle ID Mismatch**: GoogleService-Info.plist expects different bundle ID than Xcode project
- **CarPlay Disabled**: CarPlay handler temporarily disabled due to Firebase initialization errors
- **API Server Variability**: at1.api.radio-browser.info has DNS issues (de1 server working fine)

### ✅ **Resolved Issues**
- **iOS Untethered Launch**: Fixed by using Development profile + Release mode build
- **Radio-Browser API Access**: Fixed with improved multi-server fallback and emergency stations
- **Premium Subscription Persistence**: Fixed SharedPreferences storage and retrieval
- **Data Service Routing**: Fixed routing between mock data (free) and API data (premium)
- **Keychain/Codesign**: Fixed with "Allow all applications" in Keychain Access
- **Physical Device Testing**: Confirmed working on iPhone 12 Mini!
- **Emergency Fallback**: 5 verified working stations accessible when API fails

### 🛠️ **Current Status (September 23, 2025)**
1. ✅ **COMPLETED**: Premium persistence fixed with enhanced error handling
2. ✅ **COMPLETED**: Emergency fallback stations working (BBC, KEXP, Radio Paradise, Soma FM, FIP)
3. ✅ **COMPLETED**: Data service properly routes free users (22 stations) vs premium (35,000+ via API)
4. 🔄 **IN PROGRESS**: Firebase configuration restoration (temporarily bypassed)
5. 🔄 **NEXT**: Re-enable CarPlay after Firebase fix

### 📋 **Planned Features**
- **Google AdMob Integration** (next priority)
- **Proxy Server for Web Support** (required for production)
- In-app purchase integration for premium subscriptions
- Dynamic station loading (load more as user scrolls)

## Google AdMob Integration Plan

### **Implementation Strategy**
```yaml
dependencies:
  google_mobile_ads: ^5.1.0  # Add to pubspec.yaml
```

### **Ad Placement Strategy**
1. **Banner Ads**: Bottom of Home screen (above navigation)
   - Only shown in "All Stations" mode (35k+ stations)
   - Hidden in "Favorites Only" mode (premium experience)
   - Non-intrusive for music listening

2. **Future Ad Types**:
   - Interstitial ads between station switches (optional)
   - Rewarded ads for premium features
   - Native ads in station lists

### **AdMob Configuration Steps**
1. Create Google AdMob account and app
2. Add iOS App ID to `ios/Runner/Info.plist`
3. Add Android App ID to `android/app/src/main/AndroidManifest.xml`
4. Initialize Mobile Ads SDK in `main.dart`
5. Create `AdBannerWidget` component
6. Integrate banner into `home_screen_grid.dart`
7. Handle ad loading states and errors
8. Test with AdMob test ads

### **Ad Revenue Optimization**
- **Ad-Free Premium**: Charge for removing ads
- **Context Targeting**: Music/entertainment focused ads
- **Geographic Targeting**: Local radio station ads
- **Time-Based**: Different ads for different listening times

## Web Support - CORS Proxy Implementation

### **Current Issue**
The Radio-Browser API doesn't support CORS, causing failures in web browsers. Mobile apps work fine, but web deployment requires a proxy server.

### **Solution: Serverless Proxy Functions**
Implement a lightweight proxy using serverless functions to handle API requests:

#### **Option 1: Netlify Functions**
```javascript
// netlify/functions/radio-api.js
exports.handler = async (event) => {
  const { endpoint, ...params } = event.queryStringParameters;
  const baseUrl = 'https://at1.api.radio-browser.info/json';
  
  try {
    const response = await fetch(`${baseUrl}/${endpoint}?${new URLSearchParams(params)}`);
    const data = await response.json();
    
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to fetch data' }),
    };
  }
};
```

#### **Option 2: Vercel Functions**
```javascript
// api/radio-proxy.js
export default async function handler(req, res) {
  const { endpoint, ...params } = req.query;
  const baseUrl = 'https://at1.api.radio-browser.info/json';
  
  res.setHeader('Access-Control-Allow-Origin', '*');
  
  try {
    const response = await fetch(`${baseUrl}/${endpoint}?${new URLSearchParams(params)}`);
    const data = await response.json();
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch data' });
  }
}
```

#### **Option 3: Firebase Functions**
```javascript
// functions/index.js
const functions = require('firebase-functions');
const fetch = require('node-fetch');

exports.radioAPI = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  
  const endpoint = req.query.endpoint;
  const baseUrl = 'https://at1.api.radio-browser.info/json';
  
  try {
    const response = await fetch(`${baseUrl}/${endpoint}?${req.originalUrl.split('?')[1]}`);
    const data = await response.json();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch data' });
  }
});
```

### **Flutter Implementation Update**
Update `RadioBrowserAPI` to use proxy for web:

```dart
class RadioBrowserAPI {
  static String get _baseUrl {
    if (kIsWeb) {
      // Use your proxy URL for web
      return 'https://your-app.netlify.app/.netlify/functions/radio-api';
    }
    return 'https://at1.api.radio-browser.info/json';
  }
  
  // Update API calls to include endpoint parameter for web
  Future<List<Station>> getTopStations() async {
    final url = kIsWeb 
      ? '$_baseUrl?endpoint=stations/topclick&limit=100'
      : '$_baseUrl/stations/topclick?limit=100';
    // ... rest of implementation
  }
}
```

### **Deployment Steps**
1. Choose a serverless platform (Netlify/Vercel/Firebase)
2. Deploy the proxy function
3. Update Flutter app with proxy URL
4. Test web version with full API access

### **Benefits**
- ✅ Web version gets full 35,000+ stations
- ✅ Single codebase for mobile and web
- ✅ Minimal server costs (serverless)
- ✅ Can add caching and rate limiting
- ✅ Secure API key management possible

## Performance Optimization

- Lazy load station images with `cached_network_image`
- HTTP client with 15-minute cache for API calls
- Pagination for large station lists (100 stations per request)
- Error handling with fallback to favorites
- Memory optimization with `didChangeDependencies` refresh
- Monitor memory usage with Flutter DevTools
- Proxy server caching for web performance

## Troubleshooting Guide

### Issue: Only seeing 22 stations instead of 35,000+

**Diagnosis Steps:**
1. Check premium status in Settings screen
2. Look for "Premium user: Fetching from Radio-Browser API" in logs
3. Verify network connectivity

**Solutions:**
1. **If Free User**: Activate premium subscription in Settings
2. **If Premium but still 22 stations**: 
   - Force close and restart app
   - Check Settings → Premium Status
   - Use debug method: `SubscriptionService().forceActivatePremiumForDebug()`
3. **If API connection fails**: App automatically falls back to emergency stations

### Issue: Premium status not persisting after restart

**Diagnosis:**
- Check logs for "Subscription initialized: Premium=false"
- Look for SharedPreferences errors

**Solutions:**
1. Restart app and re-activate premium
2. Clear app data (iOS: Offload app, Android: Clear storage)
3. Check device storage space

### Issue: Stations not loading/connection errors

**Expected Behavior**: With 35,000+ stations, some will always be offline

**Solutions:**
1. **Try different stations** - this is normal behavior
2. **Check logs** for server fallback messages
3. **Emergency fallback**: App automatically provides working stations when API fails

### Issue: Search not finding stations

**Diagnosis:**
- Check if you have premium access
- Look for "Premium user: Searching Radio-Browser API" in logs

**Solutions:**
1. **Free users**: Search limited to 22 curated stations
2. **Premium users**: Full 35,000+ station search available
3. **Try broader terms**: "jazz", "rock", "news" work better than specific station names

### Current API Server Status

- ✅ **de1.api.radio-browser.info**: Primary server, working well
- ✅ **nl1.api.radio-browser.info**: Secondary server, working
- ✅ **fr1.api.radio-browser.info**: Tertiary server, working
- ❌ **at1.api.radio-browser.info**: DNS issues, automatic fallback

### Emergency Fallback Stations

When all API servers fail, these verified stations are available:
1. BBC Radio 1
2. KEXP 90.3 FM
3. Radio Paradise
4. Soma FM Groove Salad
5. FIP (France)

### Debug Commands

For developers testing:
```dart
// Force premium activation
SubscriptionService().forceActivatePremiumForDebug();

// Check storage state
SubscriptionService().debugPrintStorageState();

// Reset subscription
SubscriptionService().resetSubscriptionForDebug();
```