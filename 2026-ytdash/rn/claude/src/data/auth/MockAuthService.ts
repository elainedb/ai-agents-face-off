import { AuthService, SignedInUser } from './AuthService';

// UI-test-mode identity source (constitution §4): tapping `login_google_button` signs in as the
// `mockAuthEmail` extra, skipping the real Google account picker. Normal whitelist logic still runs.
export class MockAuthService implements AuthService {
  constructor(private readonly mockEmail: string | null) {}

  async signIn(): Promise<SignedInUser> {
    if (!this.mockEmail) {
      throw new Error('No mock auth email supplied');
    }
    return { email: this.mockEmail };
  }

  async signOut(): Promise<void> {
    // Nothing to tear down for the mock identity.
  }
}
