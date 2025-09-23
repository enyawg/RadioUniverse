# Apple Distribution Certificate Setup Guide

## Overview
You need an Apple Distribution certificate to create Ad Hoc and App Store builds. This is different from the Development certificate you currently have.

## Step 1: Create Certificate Signing Request (CSR)

1. **Open Keychain Access** on your Mac
   - Applications → Utilities → Keychain Access

2. **Create CSR**
   - Menu: Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority
   - Fill in:
     - Email Address: Your Apple ID email
     - Common Name: Wayne Gardner
     - CA Email Address: Leave blank
   - Select: "Saved to disk"
   - Click Continue
   - Save as: CertificateSigningRequest.certSigningRequest

## Step 2: Create Distribution Certificate

1. **Go to Apple Developer Portal**
   - https://developer.apple.com/account/resources/certificates/list

2. **Create New Certificate**
   - Click the "+" button
   - Under "Software", select "Apple Distribution"
   - Click Continue

3. **Upload CSR**
   - Click "Choose File"
   - Select the CertificateSigningRequest.certSigningRequest file you created
   - Click Continue

4. **Download Certificate**
   - Click Download
   - The file will be named: distribution.cer

5. **Install Certificate**
   - Double-click the downloaded distribution.cer file
   - Keychain Access will open and install it

## Step 3: Verify Installation

Run this command to verify:
```bash
security find-identity -v -p codesigning | grep "Apple Distribution"
```

You should see something like:
```
2) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX "Apple Distribution: Wayne Gardner (GKFMBVEMH2)"
```

## Important Notes

- This certificate is valid for all your apps
- It expires in 1 year
- You'll use this for both Ad Hoc and App Store distributions
- Keep your private key safe - back up your Keychain!

## Next Steps

After creating the Distribution certificate:
1. Return to creating the Ad Hoc provisioning profile
2. You'll now be able to select your Distribution certificate
3. Complete the Ad Hoc profile creation process