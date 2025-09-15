# Configuration Setup

This directory contains configuration files for the application.

## Auth Configuration

The `auth_config.dart` file contains sensitive configuration data (authorized email addresses) and is **not committed to version control**.

### Setup Instructions

1. **For Local Development:**
   ```bash
   # Copy template and customize with real email addresses
   cp auth_config.template.dart auth_config.dart
   ```

2. **Edit `auth_config.dart`:**
   - Replace the example email addresses with your actual authorized email addresses
   - Save the file

3. **For CI/CD:**
   - Run the setup script before analysis: `./scripts/setup_ci.sh`
   - Or manually: `dart scripts/ensure_config.dart`
   - This creates a CI-safe version with empty authorized emails list

### File Versions

- `auth_config.dart` - Not committed (contains real emails, ignored by git)
- `auth_config.template.dart` - Committed template with examples

### Example

```dart
class AuthConfig {
  static const List<String> authorizedEmails = [
    'admin@yourcompany.com',
    'user1@yourcompany.com',
    'user2@yourcompany.com',
  ];
}
```

## Security Model

- **Development:** Real emails in local `auth_config.dart` (not committed)
- **CI/Production:** Auto-generated empty list (secure default)
- **Firebase configs:** Still in .gitignore (contain API keys)

## Adding New Configuration

When adding new configuration files:

1. Create a `.template.dart` version that can be committed
2. Add the actual config file to `.gitignore`
3. Update CI setup scripts if needed
4. Document the setup process in this README