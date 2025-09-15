# Configuration Setup

This directory contains configuration files for the application.

## Auth Configuration

The `auth_config.dart` file contains sensitive configuration data (authorized email addresses) and is **not committed to version control**.

### Setup Instructions

1. **Copy the template file:**
   ```bash
   cp auth_config.template.dart auth_config.dart
   ```

2. **Edit `auth_config.dart`:**
   - Replace the example email addresses with your actual authorized email addresses
   - Save the file

3. **Security:**
   - The `auth_config.dart` file is automatically ignored by git (see `.gitignore`)
   - Never commit this file to version control
   - Keep the list of authorized emails secure

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

## Adding New Configuration

When adding new configuration files:

1. Create a `.template.dart` version that can be committed
2. Add the actual config file to `.gitignore`
3. Document the setup process in this README