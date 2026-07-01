/**
 * Real Google Sign-In seam (production path). In UI-test-mode this is never called — the login
 * button signs in as `mockAuthEmail` (constitution §4). The whitelist check that follows is
 * identical on both paths, so the tested access logic is the real logic.
 *
 * Idiomatic RN choice: @react-native-google-signin/google-signin + a google-services.json.
 * It is loaded dynamically so the app builds and runs without the native dependency present
 * (the harness never exercises this path). To fully enable real sign-in: install the package,
 * drop google-services.json into android/app, and set the webClientId below.
 */
export async function realGoogleSignIn(): Promise<{ email: string | null; error: string | null }> {
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const mod = require('@react-native-google-signin/google-signin');
    const GoogleSignin = mod.GoogleSignin;
    GoogleSignin.configure({
      // webClientId: '<from google-services.json>',
      offlineAccess: false,
    });
    await GoogleSignin.hasPlayServices();
    const userInfo = await GoogleSignin.signIn();
    const email: string | null = userInfo?.user?.email ?? userInfo?.data?.user?.email ?? null;
    return { email, error: null };
  } catch (e) {
    if (e instanceof Error && /Cannot find module/.test(e.message)) {
      return {
        email: null,
        error: 'Google Sign-In is not configured in this build. Run in UI-test mode or add google-services.json.',
      };
    }
    return { email: null, error: e instanceof Error ? e.message : 'Sign-in failed' };
  }
}
