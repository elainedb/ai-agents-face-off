// jest-setup.js

// Mock react-native modules for jsdom test environment
jest.mock('react-native', () => {
  const React = require('react');
  return {
    ActivityIndicator: 'ActivityIndicator',
    Alert: { alert: jest.fn() },
    FlatList: 'FlatList',
    Image: 'Image',
    Linking: { canOpenURL: jest.fn(async () => true), openURL: jest.fn(async () => {}) },
    Modal: ({ children }) => children,
    Platform: { OS: 'android', select: jest.fn((obj) => obj.android || obj.default) },
    Pressable: ({ children }) => React.createElement(React.Fragment, null, typeof children === 'function' ? children({ pressed: false }) : children),
    RefreshControl: 'RefreshControl',
    SafeAreaView: 'SafeAreaView',
    ScrollView: 'ScrollView',
    StatusBar: { currentHeight: 0 },
    StyleSheet: { create: (styles) => styles },
    Text: 'Text',
    View: 'View',
  };
});

jest.mock('expo-router', () => ({
  Redirect: () => null,
  Link: ({ children }) => children,
  router: { push: jest.fn(), back: jest.fn(), replace: jest.fn() },
  useRouter: () => ({ push: jest.fn(), back: jest.fn(), replace: jest.fn() }),
  useLocalSearchParams: () => ({}),
}));

jest.mock('expo-image', () => ({
  Image: 'Image',
}));

jest.mock('@react-native-google-signin/google-signin', () => ({
  GoogleSignin: {
    configure: jest.fn(),
    hasPlayServices: jest.fn(async () => true),
    isSignedIn: jest.fn(async () => false),
    signIn: jest.fn(async () => ({ user: { email: 'user1@example.com' } })),
    signOut: jest.fn(async () => undefined),
  },
  isErrorWithCode: () => false,
  statusCodes: {
    IN_PROGRESS: 'IN_PROGRESS',
    PLAY_SERVICES_NOT_AVAILABLE: 'PLAY_SERVICES_NOT_AVAILABLE',
    SIGN_IN_CANCELLED: 'SIGN_IN_CANCELLED',
  },
}));

jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(async () => null),
  removeItem: jest.fn(async () => undefined),
  setItem: jest.fn(async () => undefined),
}));

jest.mock('@gorhom/bottom-sheet', () => 'BottomSheet');
jest.mock('react-native-webview', () => ({ WebView: 'WebView' }));
jest.mock('react-native-gesture-handler', () => ({
  GestureHandlerRootView: ({ children }) => children,
}));
jest.mock('expo-constants', () => ({
  expoConfig: { android: { package: 'dev.elainedb.rn_codex' } },
}));
