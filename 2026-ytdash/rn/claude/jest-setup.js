// Mock react-native modules for jsdom test environment
jest.mock('react-native', () => ({
  Platform: { select: jest.fn((obj) => obj.web || obj.default), OS: 'web' },
  StyleSheet: { create: (styles) => styles, absoluteFillObject: {} },
  Linking: { openURL: jest.fn(), canOpenURL: jest.fn() },
  Alert: { alert: jest.fn() },
  Animated: {
    View: 'Animated.View',
    Value: jest.fn(() => ({ setValue: jest.fn() })),
    spring: jest.fn(() => ({ start: jest.fn() })),
    timing: jest.fn(() => ({ start: jest.fn() })),
  },
  Dimensions: { get: jest.fn(() => ({ width: 375, height: 812 })) },
  StatusBar: { currentHeight: 0 },
}));

jest.mock('expo-router', () => ({
  Link: ({ children }) => children,
  useRouter: () => ({ push: jest.fn(), back: jest.fn(), replace: jest.fn() }),
  router: { push: jest.fn(), back: jest.fn(), replace: jest.fn() },
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

jest.mock('@react-native-google-signin/google-signin', () => ({
  GoogleSignin: {
    configure: jest.fn(),
    hasPlayServices: jest.fn(),
    signIn: jest.fn(),
    signOut: jest.fn(),
    getCurrentUser: jest.fn(),
  },
  statusCodes: {
    SIGN_IN_CANCELLED: 'SIGN_IN_CANCELLED',
    IN_PROGRESS: 'IN_PROGRESS',
    PLAY_SERVICES_NOT_AVAILABLE: 'PLAY_SERVICES_NOT_AVAILABLE',
  },
}));

jest.mock('react-native-webview', () => ({
  WebView: 'WebView',
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
