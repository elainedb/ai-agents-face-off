import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';

import { useColorScheme } from '@/hooks/use-color-scheme';
import { initContainer } from '@/src/core/di/container';

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    initContainer();
    setReady(true);
  }, []);

  if (!ready) return null;

  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      <Stack
        screenOptions={{ headerShown: false }}
        initialRouteName="login"
      >
        <Stack.Screen name="login" />
        <Stack.Screen name="index" />
        <Stack.Screen name="main" />
        <Stack.Screen name="map" />
      </Stack>
      <StatusBar style="auto" />
    </ThemeProvider>
  );
}
