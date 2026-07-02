import * as AuthSession from 'expo-auth-session';
import Constants from 'expo-constants';

const GOOGLE_DISCOVERY = {
  authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
};

const BASE64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

// Minimal base64 decoder (no atob/Buffer assumption on Hermes) for reading the `email` claim out
// of a Google-issued OAuth id_token (a JWT: header.payload.signature, base64url-encoded).
function base64UrlDecode(input: string): string {
  const normalized = input.replace(/-/g, '+').replace(/_/g, '/');
  let output = '';
  let buffer = 0;
  let bits = 0;
  for (const char of normalized) {
    const value = BASE64_CHARS.indexOf(char);
    if (value === -1) continue;
    buffer = (buffer << 6) | value;
    bits += 6;
    if (bits >= 8) {
      bits -= 8;
      output += String.fromCharCode((buffer >> bits) & 0xff);
    }
  }
  return output;
}

function emailFromIdToken(idToken: string): string | null {
  const parts = idToken.split('.');
  if (parts.length < 2) return null;
  try {
    const payload = JSON.parse(base64UrlDecode(parts[1]));
    return typeof payload.email === 'string' ? payload.email : null;
  } catch {
    return null;
  }
}

// Real (non-UI-test-mode) Google sign-in via expo-auth-session — no native Google-Sign-In SDK
// linking or `google-services.json` required, only an OAuth client id. This workspace has no
// client id configured (see plan.md "Deviations"), so this throws a clear, catchable error until
// one is supplied; the code path is otherwise complete and exercised structurally by the
// UI-test-mode `mockAuthEmail` path, which shares the same `isAuthorized()` gate downstream.
export async function signInWithGoogle(): Promise<string | null> {
  const clientId = (Constants.expoConfig?.extra as { googleAndroidClientId?: string } | undefined)?.googleAndroidClientId;
  if (!clientId) {
    throw new Error('Google sign-in is not configured (missing OAuth client id).');
  }

  const request = new AuthSession.AuthRequest({
    clientId,
    scopes: ['openid', 'email', 'profile'],
    redirectUri: AuthSession.makeRedirectUri(),
    responseType: AuthSession.ResponseType.IdToken,
    usePKCE: false,
  });

  const result = await request.promptAsync(GOOGLE_DISCOVERY);
  if (result.type !== 'success') return null;

  const idToken = result.params.id_token;
  if (!idToken) return null;

  return emailFromIdToken(idToken);
}
