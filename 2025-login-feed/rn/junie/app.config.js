// Dynamic Expo app config to inject secrets from a local, uncommitted file.
// This file replaces app.json at build time when present.
// It reads authorized emails from `authorized-emails.local.json` (gitignored)
// and exposes them via `extra.authorizedEmails`.

const fs = require('fs');
const path = require('path');

function parseEnvList(value) {
  if (!value || typeof value !== 'string') return [];
  return value
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
}

function tryReadJsonArray(filePath, key) {
  try {
    if (fs.existsSync(filePath)) {
      const raw = fs.readFileSync(filePath, 'utf-8');
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed)) return parsed;
      if (key && Array.isArray(parsed?.[key])) return parsed[key];
    }
  } catch (e) {
    console.warn(`[app.config] Failed to read ${path.basename(filePath)}:`, e);
  }
  return [];
}

function loadAuthorizedEmails() {
  // 1) Environment variable takes precedence (works well in CI/EAS):
  const fromEnv = parseEnvList(process.env.EXPO_PUBLIC_AUTHORIZED_EMAILS || process.env.EXPO_AUTHORIZED_EMAILS);
  if (fromEnv.length > 0) return { list: fromEnv, source: 'env' };

  // 2) Local uncommitted file (preferred for local dev):
  const localPath = path.resolve(__dirname, 'authorized-emails.local.json');
  const fromLocal = tryReadJsonArray(localPath, 'authorizedEmails');
  if (fromLocal.length > 0) return { list: fromLocal, source: 'authorized-emails.local.json' };

  // 3) Example fallback to avoid breaking login unexpectedly, warns loudly:
  const examplePath = path.resolve(__dirname, 'authorized-emails.local.example.json');
  const fromExample = tryReadJsonArray(examplePath, undefined);
  if (fromExample.length > 0) {
    console.warn('[app.config] Using authorized-emails.local.example.json as fallback. Create authorized-emails.local.json or set EXPO_PUBLIC_AUTHORIZED_EMAILS to override.');
    return { list: fromExample, source: 'authorized-emails.local.example.json' };
  }

  // 4) Last resort: empty list.
  console.warn('[app.config] No authorized emails configured. Login will be blocked until configured.');
  return { list: [], source: 'empty' };
}

function loadYoutubeApiKey() {
  // 1) Environment variable (EXPO_PUBLIC_ will be embedded in the app at runtime)
  const fromEnv = process.env.EXPO_PUBLIC_YOUTUBE_API_KEY || process.env.YOUTUBE_API_KEY;
  if (fromEnv && typeof fromEnv === 'string') return { key: fromEnv, source: 'env' };

  // 2) Local uncommitted config.js at project root
  try {
    const cfgPath = path.resolve(__dirname, 'config.js');
    if (fs.existsSync(cfgPath)) {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const mod = require(cfgPath);
      const k = mod?.youtubeApiKey || mod?.default?.youtubeApiKey;
      if (k) return { key: String(k), source: 'config.js' };
    }
  } catch (e) {
    console.warn('[app.config] Failed to read config.js for youtubeApiKey:', e);
  }

  // 3) Last resort: undefined
  return { key: undefined, source: 'empty' };
}

module.exports = ({ config }) => {
  // If app.json exists, Expo passes it as `config`. Otherwise, start from an empty object
  const base = config ?? {};

  const { list: authorizedEmails, source } = loadAuthorizedEmails();
  const { key: youtubeApiKey, source: ytSource } = loadYoutubeApiKey();

  return {
    ...base,
    extra: {
      ...(base.extra || {}),
      authorizedEmails,
      __authorizedEmailsSource: source,
      youtubeApiKey,
      __youtubeApiKeySource: ytSource,
    },
  };
};
