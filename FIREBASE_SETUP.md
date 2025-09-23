# Firebase Setup Guide for RadioUniverse

## Prerequisites

1. **Install Firebase CLI**
   ```bash
   # Install Node.js first if you don't have it
   # Visit: https://nodejs.org/
   
   # Then install Firebase CLI
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it: `radio-universe` (or your preferred name)
4. Enable Google Analytics (optional)
5. Wait for project creation

## Step 2: Configure Flutter App

1. In your terminal, run:
   ```bash
   export PATH="$PATH:$HOME/.pub-cache/bin"
   flutterfire configure
   ```

2. Select your project from the list
3. Choose platforms: ✓ iOS, ✓ Android
4. Accept the default bundle IDs or customize them

This will generate:
- `lib/firebase_options.dart`
- iOS: `ios/Runner/GoogleService-Info.plist`
- Android: `android/app/google-services.json`

## Step 3: Enable Firebase Services

In the [Firebase Console](https://console.firebase.google.com/):

### Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Start in **test mode** (for development)
4. Choose your region (closest to your users)

### Authentication (Optional for future)
1. Go to Authentication
2. Click "Get started"
3. Enable Email/Password or Google Sign-In

### Storage (For station logos)
1. Go to Storage
2. Click "Get started"
3. Start in test mode

## Step 4: Update Flutter Code

1. Update `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const RadioUniverseApp());
}
```

## Step 5: Platform-Specific Setup

### iOS
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Under "Signing & Capabilities", ensure you have a valid team
4. Minimum iOS deployment target: 11.0

### Android
1. Ensure `android/app/build.gradle` has:
   ```gradle
   minSdkVersion 21
   ```

2. The google-services plugin should be automatically added

## Step 6: Test Firebase Connection

Run the app:
```bash
flutter run
```

Check Firebase Console for:
- Active users in Analytics
- Firestore database ready
- No errors in the console

## Firestore Structure

```
/stations
  /{stationId}
    - name: string
    - streamUrl: string
    - logoUrl: string
    - genre: string
    - country: string
    - tags: array
    - popularity: number

/users (future feature)
  /{userId}
    - favorites: array of stationIds
    - recentlyPlayed: array
    - preferences: map

/customStations
  /{userId}
    /{stationId}
      - name: string
      - streamUrl: string
      - createdAt: timestamp
```

## Security Rules (Production)

For production, update Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to stations
    match /stations/{document} {
      allow read: if true;
      allow write: if false;
    }
    
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Custom stations
    match /customStations/{userId}/{document} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Current Status (September 23, 2025)

⚠️ **Firebase Temporarily Bypassed**: Due to configuration issues after `flutterfire configure`, Firebase initialization is currently bypassed on iOS. The app uses MockFirebaseService for curated stations and Radio-Browser API for premium features.

### Workaround in Place:
- iOS: Firebase initialization skipped, full functionality via Radio-Browser API
- Android/Web: Firebase should work normally
- All features working: Premium subscriptions, 35,000+ stations, favorites

### To Restore Firebase (when ready):
1. Fix bundle ID mismatch in GoogleService-Info.plist
2. Restore proper Firebase configuration
3. Re-enable CarPlay integration
4. Test cross-device sync features

## Next Steps

1. ✅ **COMPLETED**: Radio-Browser API integration with fallbacks
2. ✅ **COMPLETED**: Premium subscription persistence
3. 🔄 **IN PROGRESS**: Firebase configuration restoration
4. 🔄 **PENDING**: CarPlay re-integration after Firebase fix
5. 📝 **PLANNED**: Firebase Analytics events