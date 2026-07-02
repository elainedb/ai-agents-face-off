const fs = require('fs');
const path = require('path');

function parseEnvFile(filePath) {
  const result = {};
  if (!fs.existsSync(filePath)) return result;
  const content = fs.readFileSync(filePath, 'utf8');
  for (const line of content.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx === -1) continue;
    const key = trimmed.slice(0, idx).trim();
    const value = trimmed.slice(idx + 1).trim();
    result[key] = value;
  }
  return result;
}

module.exports = ({ config }) => {
  const secrets = parseEnvFile(path.join(__dirname, 'config', 'secrets.env'));
  return {
    ...config,
    extra: {
      ...config.extra,
      youtubeApiKey: secrets.YOUTUBE_API_KEY ?? '',
      authorizedEmails: secrets.AUTHORIZED_EMAILS ?? '',
      googleWebClientId: secrets.GOOGLE_WEB_CLIENT_ID ?? '',
    },
  };
};
