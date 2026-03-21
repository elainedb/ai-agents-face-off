// Mock react-native modules for jsdom test environment
jest.mock('react-native', () => ({
  Platform: { select: jest.fn((obj) => obj.android || obj.default), OS: 'android' },
  StyleSheet: { create: (styles) => styles },
  StatusBar: { currentHeight: 24 },
  Alert: { alert: jest.fn() },
  Linking: { canOpenURL: jest.fn(), openURL: jest.fn() },
}));

jest.mock('expo-router', () => ({
  Link: ({ children }) => children,
  useRouter: () => ({ push: jest.fn(), back: jest.fn(), replace: jest.fn() }),
  useLocalSearchParams: () => ({}),
  Redirect: () => null,
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
    hasPlayServices: jest.fn().mockResolvedValue(true),
    signIn: jest.fn().mockResolvedValue({ data: { user: { email: 'test@test.com' } } }),
    signOut: jest.fn().mockResolvedValue(null),
    getCurrentUser: jest.fn().mockReturnValue(null),
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
    getItem: jest.fn().mockResolvedValue(null),
    setItem: jest.fn().mockResolvedValue(null),
    removeItem: jest.fn().mockResolvedValue(null),
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
    default: React.forwardRef((props, ref) => props.children),
    BottomSheetView: ({ children }) => children,
  };
});
