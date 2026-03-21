// Mock react-native modules for jsdom test environment
jest.mock('react-native', () => ({
  Platform: { OS: 'android', select: jest.fn((obj) => obj.android || obj.default) },
  StyleSheet: { create: (styles) => styles },
  Alert: { alert: jest.fn() },
  Linking: { openURL: jest.fn(), canOpenURL: jest.fn(() => Promise.resolve(false)) },
  StatusBar: { currentHeight: 24 },
}));

jest.mock('expo-router', () => ({
  Link: ({ children }) => children,
  Redirect: ({ href }) => null,
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

jest.mock('@react-native-google-signin/google-signin', () => ({
  GoogleSignin: {
    configure: jest.fn(),
    signIn: jest.fn(),
    signOut: jest.fn(),
    getCurrentUser: jest.fn(() => Promise.resolve(null)),
    hasPlayServices: jest.fn(() => Promise.resolve(true)),
  },
  statusCodes: {
    SIGN_IN_CANCELLED: 'SIGN_IN_CANCELLED',
    IN_PROGRESS: 'IN_PROGRESS',
    PLAY_SERVICES_NOT_AVAILABLE: 'PLAY_SERVICES_NOT_AVAILABLE',
  },
}));

jest.mock('@react-native-async-storage/async-storage', () => ({
  __esModule: true,
  default: {
    getItem: jest.fn(() => Promise.resolve(null)),
    setItem: jest.fn(() => Promise.resolve()),
    removeItem: jest.fn(() => Promise.resolve()),
  },
}));

jest.mock('react-native-webview', () => ({
  WebView: 'WebView',
}));

jest.mock('react-native-gesture-handler', () => ({
  GestureHandlerRootView: ({ children }) => children,
}));

jest.mock('@gorhom/bottom-sheet', () => {
  const React = require('react');
  return {
    __esModule: true,
    default: React.forwardRef(({ children }, ref) => children),
    BottomSheetView: ({ children }) => children,
  };
});

jest.mock('react-native-reanimated', () => ({
  default: {
    createAnimatedComponent: (component) => component,
  },
  useSharedValue: jest.fn((init) => ({ value: init })),
  useAnimatedStyle: jest.fn(() => ({})),
  withTiming: jest.fn((val) => val),
  withRepeat: jest.fn((val) => val),
  withSequence: jest.fn((val) => val),
}));

jest.mock('@/config.json', () => ({
  youtubeApiKey: 'test-api-key',
  authorizedEmails: ['test@example.com'],
}), { virtual: true });

jest.mock('@/config.js', () => ({
  youtubeApiKey: 'test-api-key',
}), { virtual: true });
