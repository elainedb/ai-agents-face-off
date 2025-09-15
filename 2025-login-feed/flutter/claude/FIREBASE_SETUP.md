# Firebase Setup Guide

This project uses Firebase for authentication. The Firebase configuration files contain sensitive API keys and are **not committed to version control**.

## Prerequisites

1. A Firebase project with Authentication enabled
2. Google Sign-In configured in Firebase Console
3. Android and iOS apps registered in your Firebase project

## Setup Instructions

### 1. Auth Configuration

```bash
# Copy and customize the auth config
cp lib/config/auth_config.template.dart lib/config/auth_config.dart
```

Edit `lib/config/auth_config.dart` and replace the example emails with authorized user email addresses:

```dart
class AuthConfig {
  static const List<String> authorizedEmails = [
    'admin@yourcompany.com',
    'user1@yourcompany.com',
    // Add more authorized emails here
  ];
}
```

### 2. Android Configuration

```bash
# Copy the template
cp android/app/google-services.json.template android/app/google-services.json
```

**Get your `google-services.json` file:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > General tab
4. Under "Your apps" find your Android app
5. Click "Download google-services.json"
6. Replace the template file with the downloaded file

### 3. iOS Configuration

```bash
# Copy the template
cp ios/Runner/GoogleService-Info.plist.template ios/Runner/GoogleService-Info.plist
```

**Get your `GoogleService-Info.plist` file:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > General tab
4. Under "Your apps" find your iOS app
5. Click "Download GoogleService-Info.plist"
6. Replace the template file with the downloaded file

### 4. Enable Google Sign-In

1. Go to Firebase Console > Authentication > Sign-in method
2. Enable Google Sign-In provider
3. Add your support email

### 5. Add SHA Fingerprints (Android)

**Get your SHA-1 fingerprint:**
```bash
cd android
./gradlew signingReport
```

Copy the SHA1 fingerprint from the debug config and add it to Firebase:
1. Firebase Console > Project Settings > General tab
2. Find your Android app
3. Click "Add fingerprint"
4. Paste the SHA-1 fingerprint

### 6. Verify Setup

Run the app and test Google Sign-In:
```bash
flutter run
```

## Security Notes

⚠️ **Important Security Information:**

- **Never commit** `google-services.json` or `GoogleService-Info.plist` to version control
- **Never commit** `lib/config/auth_config.dart` to version control
- These files contain sensitive API keys and configuration data
- Each developer needs their own copy of these files
- Use different Firebase projects for development, staging, and production

## Troubleshooting

### Google Sign-In Error (Android)

If you see `PlatformException(sign_in_failed, com.google.android.gms.common.api.j: 10:, null, null)`:

1. Verify SHA-1 fingerprint is added to Firebase Console
2. Ensure OAuth client is configured for your app
3. Download fresh `google-services.json` after adding fingerprint
4. Clean and rebuild the app

### Missing Configuration Files

If you get import errors:
1. Ensure you've copied the template files
2. Verify the files are in the correct locations
3. Run `flutter clean && flutter pub get`

## File Structure

```
lib/config/
├── auth_config.dart              # ❌ Not committed (sensitive)
├── auth_config.template.dart     # ✅ Committed (template)
└── README.md                     # ✅ Committed (documentation)

android/app/
├── google-services.json          # ❌ Not committed (sensitive)
└── google-services.json.template # ✅ Committed (template)

ios/Runner/
├── GoogleService-Info.plist          # ❌ Not committed (sensitive)
└── GoogleService-Info.plist.template # ✅ Committed (template)
```