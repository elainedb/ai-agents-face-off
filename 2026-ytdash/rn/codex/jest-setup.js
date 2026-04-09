// jest-setup.js

global.__DEV__ = true;

// Mock react-native modules for jsdom test environment
jest.mock('react-native', () => ({
  Platform: { select: jest.fn((obj) => obj.web || obj.default) },
  StyleSheet: { create: (styles) => styles },
  Alert: { alert: jest.fn() },
  Linking: {
    canOpenURL: jest.fn(async () => false),
    openURL: jest.fn(async () => undefined),
  },
}));

jest.mock('expo-router', () => ({
  Link: ({ children }) => children,
  Stack: {
    Screen: ({ children }) => children ?? null,
  },
  Redirect: () => null,
  useRouter: () => ({ push: jest.fn(), back: jest.fn(), replace: jest.fn() }),
  useLocalSearchParams: () => ({}),
}));

jest.mock('expo-image', () => ({
  Image: 'Image',
}));

jest.mock('expo-haptics', () => ({
  impactAsync: jest.fn(),
  ImpactFeedbackStyle: { Light: 'light' },
}));

jest.mock('expo-splash-screen', () => ({
  preventAutoHideAsync: jest.fn(),
  hideAsync: jest.fn(),
}));

jest.mock('expo-sqlite', () => ({
  openDatabaseAsync: jest.fn(async () => ({
    execAsync: jest.fn(async () => undefined),
    getAllAsync: jest.fn(async () => []),
    getFirstAsync: jest.fn(async () => null),
  })),
}));

jest.mock('react-native-webview', () => ({
  WebView: 'WebView',
}));

jest.mock('@react-native-google-signin/google-signin', () => ({
  statusCodes: {
    SIGN_IN_CANCELLED: 'SIGN_IN_CANCELLED',
    IN_PROGRESS: 'IN_PROGRESS',
    PLAY_SERVICES_NOT_AVAILABLE: 'PLAY_SERVICES_NOT_AVAILABLE',
  },
  isErrorWithCode: () => false,
  GoogleSignin: {
    configure: jest.fn(),
    hasPlayServices: jest.fn(async () => true),
    signIn: jest.fn(async () => ({
      user: {
        id: '1',
        name: 'Test User',
        email: 'user1@example.com',
        photo: null,
      },
    })),
    signOut: jest.fn(async () => undefined),
    getCurrentUser: jest.fn(() => null),
  },
}));

jest.mock('@react-native-firebase/perf', () => () => ({
  setPerformanceCollectionEnabled: jest.fn(async () => undefined),
}));
