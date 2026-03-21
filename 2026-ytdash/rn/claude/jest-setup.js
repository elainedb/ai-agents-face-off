// Mock react-native modules for jsdom test environment
jest.mock('react-native', () => ({
  Platform: { select: jest.fn((obj) => obj.web || obj.default) },
  StyleSheet: { create: (styles) => styles },
}));

jest.mock('expo-router', () => ({
  Link: ({ children }) => children,
  useRouter: () => ({ push: jest.fn(), back: jest.fn() }),
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

jest.mock('@react-native-firebase/app', () => ({
  __esModule: true,
  default: {
    apps: [],
    initializeApp: jest.fn(),
  },
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
