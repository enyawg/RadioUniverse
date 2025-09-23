# Quick Start: RadioUniverse Ad Hoc Distribution

## Current Status
- ✅ Project configured for Ad Hoc distribution
- ✅ Using "Apple Distribution" certificate type
- ⏳ Need to create Distribution certificate
- ⏳ Need to create Ad Hoc provisioning profile

## Step-by-Step Process

### 1. Create Distribution Certificate (One Time)
1. Follow instructions in DISTRIBUTION_CERTIFICATE_GUIDE.md
2. This takes about 5 minutes

### 2. Create Ad Hoc Provisioning Profile
1. Go to: https://developer.apple.com/account/resources/profiles/list
2. Click "+" → "Ad Hoc" → Continue
3. Select: com.waynegardner.radioUniverse
4. Select: Your new Apple Distribution certificate
5. Select: Your iPhone device
6. Name it: "RadioUniverse Ad Hoc"
7. Download and double-click to install

### 3. Build the App
```bash
cd /Users/wayneg/~~RadioUniverse/RadioUniverse
./build_adhoc.sh
```

### 4. Create Archive in Xcode
1. Open: `open ios/Runner.xcworkspace`
2. Select: "Any iOS Device (arm64)"
3. Menu: Product → Archive
4. Wait for archive to complete

### 5. Export Ad Hoc IPA
1. In Organizer window that appears
2. Click "Distribute App"
3. Select "Ad Hoc" → Next
4. Select "Export" → Next
5. Choose your Distribution certificate
6. Select "RadioUniverse Ad Hoc" profile
7. Export to Desktop

### 6. Install on iPhone
Option A - Using Apple Configurator 2:
1. Connect iPhone via USB
2. Open Apple Configurator 2
3. Drag IPA file to your device

Option B - Using Diawi:
1. Go to https://www.diawi.com
2. Upload IPA file
3. Open link on iPhone and install

## Success Indicators
- ✅ App runs without USB connection
- ✅ "GKFMBVEMH2" appears in Settings → General → VPN & Device Management
- ✅ App doesn't crash when unplugged
- ✅ Can close and reopen app normally

## Troubleshooting
- Certificate not found? → Complete DISTRIBUTION_CERTIFICATE_GUIDE.md first
- Profile not installing? → Make sure device UDID is included
- App won't install? → Check bundle ID matches exactly