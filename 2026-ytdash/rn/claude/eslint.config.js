const expoConfig = require('eslint-config-expo/flat');

module.exports = [
  ...expoConfig,
  {
    ignores: ['android/**', 'modules/**/android/**', 'modules/**/ios/**', 'dist/**', 'node_modules/**', '.claude/**'],
  },
  {
    files: ['app.config.js', 'jest.config.js'],
    languageOptions: {
      globals: {
        __dirname: 'readonly',
        require: 'readonly',
        module: 'readonly',
      },
    },
  },
];
