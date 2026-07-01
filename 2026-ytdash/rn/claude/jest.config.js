/**
 * Unit tests target the pure domain/data logic (auth, sort, filter, cache, api aggregation).
 * They don't render React, so a self-contained ts-jest + node environment is simpler and more
 * robust than the full RN preset. The only native import (AsyncStorage) is mocked in jest.setup.js.
 */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  setupFiles: ['<rootDir>/jest.setup.js'],
  testMatch: ['<rootDir>/__tests__/**/*.test.ts'],
  transform: {
    '^.+\\.tsx?$': ['ts-jest', { diagnostics: false }],
  },
};
