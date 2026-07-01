// The UI-test-mode launch config, surfaced from the Android intent extras (constitution §4).
export type NativeTestConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  apiBaseUrl: string | null;
  apiKey: string | null;
  authorizedEmails: string | null;
  captureExternalLinks: boolean;
};
