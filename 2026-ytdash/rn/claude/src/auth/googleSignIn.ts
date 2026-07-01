// Real Google Sign-In seam. In UI-test-mode the mock email is used instead (constitution §4), so
// this is only exercised in production. A full implementation wires
// `@react-native-google-signin/google-signin` + Firebase using the project's google-services.json.
// That native config is not present in this workspace (only a YouTube API key is provided), so the
// real interactive sign-in is a documented gap; the whitelist/domain logic it feeds is fully
// implemented and unit-tested. See BUILD-REPORT.md.
export async function realGoogleSignIn(): Promise<string | null> {
  try {
    // Dynamically resolved so its absence never breaks the mock build.
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const mod = require('@react-native-google-signin/google-signin');
    const GoogleSignin = mod?.GoogleSignin;
    if (!GoogleSignin) return null;
    await GoogleSignin.hasPlayServices();
    const info = await GoogleSignin.signIn();
    return info?.user?.email ?? info?.data?.user?.email ?? null;
  } catch {
    return null;
  }
}
