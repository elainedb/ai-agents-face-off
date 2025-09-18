# Configuration Setup

This directory contains configuration files for the application.

## Configuration Files

Both configuration files contain sensitive data and are **not committed to version control**:
- `auth_config.dart` - Contains authorized email addresses
- `config.dart` - Contains YouTube API key

## Auth Configuration

The `auth_config.dart` file contains authorized email addresses for Google Sign-In access control.

### Setup Instructions

1. **For Local Development:**
   ```bash
   # Copy templates and customize with real data
   cp auth_config.template.dart auth_config.dart
   cp config.template.dart config.dart
   ```

2. **Edit configuration files:**

   **auth_config.dart:**
   - Replace the example email addresses with your actual authorized email addresses

   **config.dart:**
   - Replace `YOUR_YOUTUBE_API_KEY` with your actual YouTube Data API v3 key

3. **For CI/CD:**
   - Run the setup script before analysis: `dart scripts/ensure_config.dart`
   - This creates CI-safe versions with placeholder values

### File Versions

**Authentication:**
- `auth_config.dart` - Not committed (contains real emails, ignored by git)
- `auth_config.template.dart` - Committed template with examples

**YouTube API:**
- `config.dart` - Not committed (contains API key, ignored by git)
- `config.template.dart` - Committed template with placeholder

### Examples

**auth_config.dart:**
```dart
class AuthConfig {
  static const List<String> authorizedEmails = [
    'admin@yourcompany.com',
    'user1@yourcompany.com',
    'user2@yourcompany.com',
  ];
}
```

**config.dart:**
```dart
class Config {
  static const String youtubeApiKey = 'AIzaSyC1234567890abcdefgh...';
}
```

## Security Model

- **Development:** Real emails and API keys in local config files (not committed)
- **CI/Production:** Auto-generated placeholders (secure defaults)
- **Firebase configs:** Still in .gitignore (contain API keys)
- **API Keys:** Never committed to repository

## Adding New Configuration

When adding new configuration files:

1. Create a `.template.dart` version that can be committed
2. Add the actual config file to `.gitignore`
3. Update CI setup scripts if needed
4. Document the setup process in this README