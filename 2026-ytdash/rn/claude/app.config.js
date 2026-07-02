const fs = require('fs');
const path = require('path');

// config/secrets.env is gitignored (see .gitignore) — never committed. It supplies the
// production API key + whitelist for REAL (non-UI-test-mode) runs. UI-test-mode always overrides
// these via launch-intent extras (constitution.md §4), so this is only the production fallback.
function loadSecrets() {
  const secretsPath = path.join(__dirname, 'config', 'secrets.env');
  const out = {};
  if (!fs.existsSync(secretsPath)) return out;
  const raw = fs.readFileSync(secretsPath, 'utf8');
  for (const line of raw.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq === -1) continue;
    out[trimmed.slice(0, eq).trim()] = trimmed.slice(eq + 1).trim();
  }
  return out;
}

const secrets = loadSecrets();

module.exports = {
  expo: {
    name: 'expo-scaffold.WQ8FGs',
    slug: 'expo-scaffold.WQ8FGs',
    version: '1.0.0',
    orientation: 'portrait',
    icon: './assets/icon.png',
    userInterfaceStyle: 'light',
    ios: {
      supportsTablet: true,
    },
    android: {
      adaptiveIcon: {
        backgroundColor: '#E6F4FE',
        foregroundImage: './assets/android-icon-foreground.png',
        backgroundImage: './assets/android-icon-background.png',
        monochromeImage: './assets/android-icon-monochrome.png',
      },
      predictiveBackGestureEnabled: false,
      package: 'com.example.ytdash_rn',
    },
    web: {
      favicon: './assets/favicon.png',
    },
    plugins: [
      [
        'expo-build-properties',
        {
          android: {
            usesCleartextTraffic: true,
          },
        },
      ],
    ],
    extra: {
      // Production (non-UI-test-mode) fallbacks — never hardcoded, read from the gitignored
      // config/secrets.env at build time. UI-test-mode always overrides via launch extras.
      youtubeApiKey: secrets.YOUTUBE_API_KEY || '',
      authorizedEmails: secrets.AUTHORIZED_EMAILS || '',
    },
  },
};
