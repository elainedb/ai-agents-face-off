# Welcome to your Expo app 👋

This is an [Expo](https://expo.dev) project created with [`create-expo-app`](https://www.npmjs.com/package/create-expo-app).

## Get started

1. Install dependencies

   ```bash
   npm install
   ```

2. Start the app

   ```bash
   npx expo start
   ```

In the output, you'll find options to open the app in a

- [development build](https://docs.expo.dev/develop/development-builds/introduction/)
- [Android emulator](https://docs.expo.dev/workflow/android-studio-emulator/)
- [iOS simulator](https://docs.expo.dev/workflow/ios-simulator/)
- [Expo Go](https://expo.dev/go), a limited sandbox for trying out app development with Expo

You can start developing by editing the files inside the **app** directory. This project uses [file-based routing](https://docs.expo.dev/router/introduction).

## Get a fresh project

When you're ready, run:

```bash
npm run reset-project
```

This command will move the starter code to the **app-example** directory and create a blank **app** directory where you can start developing.

## Learn more

To learn more about developing your project with Expo, look at the following resources:

- [Expo documentation](https://docs.expo.dev/): Learn fundamentals, or go into advanced topics with our [guides](https://docs.expo.dev/guides).
- [Learn Expo tutorial](https://docs.expo.dev/tutorial/introduction/): Follow a step-by-step tutorial where you'll create a project that runs on Android, iOS, and the web.

## Join the community

Join our community of developers creating universal apps.

- [Expo on GitHub](https://github.com/expo/expo): View our open source platform and contribute.
- [Discord community](https://chat.expo.dev): Chat with Expo users and ask questions.


## Project Setup Notes

- Authorized Emails for Login:
  - Configure allowed emails via one of these methods:
    - Set environment variable EXPO_PUBLIC_AUTHORIZED_EMAILS="email1@example.com,email2@example.com" OR
    - Create an authorized-emails.local.json at the repo root with an array of emails, or use the provided authorized-emails.local.example.json as a template.
  - These are injected into Expo config by app.config.js and used by the Login screen.

- YouTube Data API Key:
  - Preferred: set environment variable EXPO_PUBLIC_YOUTUBE_API_KEY="YOUR_YOUTUBE_API_KEY" (works locally and in CI/EAS).
  - Alternatively for local dev: copy config.example.js to config.js in the repo root and set export const youtubeApiKey = "YOUR_YOUTUBE_API_KEY". config.js is gitignored.
  - app.config.js injects the key into Expo config extras, and the app reads it from there. No direct import of config.js is needed.
