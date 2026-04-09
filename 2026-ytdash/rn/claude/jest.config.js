module.exports = {
  testEnvironment: 'jsdom',
  setupFiles: ['./jest-setup.js'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  transform: {
    '^.+\\.[tj]sx?$': 'babel-jest',
  },
  collectCoverageFrom: [
    'app/**/*.{ts,tsx}',
    'components/**/*.{ts,tsx}',
    'hooks/**/*.{ts,tsx}',
    'src/**/*.{ts,tsx}',
    '!src/config/auth-config.ts',
    '!src/config/api-config.ts',
    '!**/*.d.ts',
  ],
  transformIgnorePatterns: [
    'node_modules/(?!(expo|expo-.*|@expo|react-native|@react-native|@react-navigation|zustand)/)',
  ],
};
