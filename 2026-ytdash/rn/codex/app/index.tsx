import { useRouter } from 'expo-router';
import { useEffect } from 'react';

import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';

export default function IndexScreen() {
  const router = useRouter();
  const { status, checkAuthStatus } = useAuthStore();

  useEffect(() => {
    checkAuthStatus().catch(() => undefined);
  }, [checkAuthStatus]);

  useEffect(() => {
    if (status === 'authenticated') {
      router.replace('/main');
      return;
    }

    if (status === 'unauthenticated' || status === 'error') {
      router.replace('/login');
    }
  }, [router, status]);

  return null;
}
