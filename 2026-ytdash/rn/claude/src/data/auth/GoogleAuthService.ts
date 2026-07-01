import { AuthService, SignedInUser } from './AuthService';

// Production identity source. Real Google Sign-In requires a `google-services.json` / OAuth web
// client id, which is NOT provisioned in this workspace (see BUILD-REPORT.md). Rather than crash,
// this surfaces a visible, explicit error (constitution §6) that the UI renders as
// `login_error_message`. Drop in google-services.json + @react-native-google-signin and replace the
// body below with GoogleSignin.signIn() to activate the real flow — the whitelist logic is unchanged.
export class GoogleAuthService implements AuthService {
  async signIn(): Promise<SignedInUser> {
    throw new Error(
      'Google Sign-In is not configured (missing google-services.json / OAuth client). ' +
        'Provide credentials to enable production sign-in.'
    );
  }

  async signOut(): Promise<void> {
    // No-op until the real provider is configured.
  }
}
