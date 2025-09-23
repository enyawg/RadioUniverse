# Ad Hoc Provisioning Profile Setup for RadioUniverse

## Prerequisites
- Apple Developer Account (paid)
- Access to Apple Developer Portal
- Your iPhone's UDID already registered

## Steps to Create Ad Hoc Provisioning Profile

### 1. Go to Apple Developer Portal
Visit: https://developer.apple.com/account/resources/profiles/list

### 2. Create New Profile
1. Click the "+" button
2. Select "Ad Hoc" under Distribution
3. Click "Continue"

### 3. Select App ID
1. Choose "com.waynegardner.radioUniverse" from the dropdown
2. Click "Continue"

### 4. Select Certificate
1. Select your distribution certificate (GKFMBVEMH2)
2. Click "Continue"

### 5. Select Devices
1. Check all devices you want to install on
2. Your iPhone (00008101-000918312EF8001E) should be in the list
3. Click "Continue"

### 6. Name the Profile
1. Name it: "RadioUniverse Ad Hoc"
2. Click "Generate"

### 7. Download and Install
1. Download the .mobileprovision file
2. Double-click to install in Xcode
3. The file will be copied to:
   ~/Library/Developer/Xcode/UserData/Provisioning Profiles/

## Verify Installation
Run this command to verify:
```bash
security cms -D -i ~/Downloads/RadioUniverse_Ad_Hoc.mobileprovision | grep -A1 "Name"
```

## Next Steps
After creating the profile, we'll update the Xcode project to use it.