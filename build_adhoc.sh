#!/bin/bash

# RadioUniverse Ad Hoc Build Script
# This script builds the app for Ad Hoc distribution

echo "🚀 Building RadioUniverse for Ad Hoc Distribution..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Podfile.lock

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Install pods
echo "🍎 Installing CocoaPods..."
cd ios && pod install && cd ..

# Build the app
echo "🔨 Building release version..."
flutter build ios --release

echo "✅ Build complete!"
echo ""
echo "📱 Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Select 'Any iOS Device (arm64)' as the destination"
echo "3. Product > Archive"
echo "4. In Organizer, select the archive and click 'Distribute App'"
echo "5. Choose 'Ad Hoc' distribution"
echo "6. Follow the wizard to export the .ipa file"
echo ""
echo "💡 To install on your device:"
echo "- Use Apple Configurator 2"
echo "- Or use Xcode's Devices window"
echo "- Or use a service like Diawi.com"