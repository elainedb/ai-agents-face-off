// Mock react-native modules for jsdom test environment
jest.mock('react-native', () => ({
  Platform: { select: jest.fn((obj) => obj.web || obj.default), OS: 'android' },
  StyleSheet: { create: (styles) => styles },
  Alert: { alert: jest.fn() },
  Linking: { openURL: jest.fn(), canOpenURL: jest.fn() },
  Animated: {
    View: 'Animated.View',
    Value: jest.fn(() => ({
      interpolate: jest.fn(),
    })),
    spring: jest.fn(() => ({ start: jest.fn() })),
    timing: jest.fn(() => ({ start: jest.fn() })),
  },
  Dimensions: { get: jest.fn(() => ({ width: 375, height: 812 })) },
  StatusBar: { currentHeight: 24 },
}));

jest.mock('expo-router', () => ({
  Link: ({ children }) => children,
  router: { push: jest.fn(), back: jest.fn(), replace: jest.fn() },
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
  openDatabaseAsync: jest.fn(),
}));

jest.mock('react-native-webview', () => ({
  WebView: 'WebView',
}));

jest.mock('@react-native-google-signin/google-signin', () => ({
  GoogleSignin: {
    configure: jest.fn(),
    hasPlayServices: jest.fn(),
    signIn: jest.fn(),
    signOut: jest.fn(),
    getCurrentUser: jest.fn(),
  },
  isSuccessResponse: jest.fn(),
}));

jest.mock('@react-native-firebase/app', () => ({
  __esModule: true,
  default: {
    apps: [],
    initializeApp: jest.fn(),
  },
}));

jest.mock('@react-native-firebase/perf', () => ({
  __esModule: true,
  default: jest.fn(() => ({
    setPerformanceCollectionEnabled: jest.fn(),
  })),
}));

jest.mock('@react-native-firebase/auth', () => {
  const mockAuth = jest.fn(() => ({
    currentUser: null,
    onAuthStateChanged: jest.fn(),
    signInWithCredential: jest.fn(),
    signOut: jest.fn(),
  }));
  mockAuth.GoogleAuthProvider = {
    credential: jest.fn(),
  };
  return {
    __esModule: true,
    default: mockAuth,
  };
});
