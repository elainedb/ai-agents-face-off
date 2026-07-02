import React from 'react';
import { Redirect } from 'expo-router';
import { useAuthStore } from '../src/state/authStore';

export default function Index() {
  const status = useAuthStore((s) => s.status);
  return <Redirect href={status === 'signedIn' ? '/home' : '/login'} />;
}
