import AsyncStorage from '@react-native-async-storage/async-storage';
import { getTestConfig } from './config';

const AUTH_USER_KEY = 'ytdash_auth_user';

export interface User {
  email: string;
}

export async function login(email: string): Promise<User> {
  const config = await getTestConfig();
  let whitelistStr = config.authorizedEmails;
  
  if (!whitelistStr) {
    // default hardcoded if not in test config (from spec)
    whitelistStr = 'user1@example.com,user2@example.com';
  }
  const whitelist = whitelistStr.split(',').map(s => s.trim().toLowerCase());
  
  if (!whitelist.includes(email.toLowerCase())) {
    throw new Error('Unauthorized_email');
  }
  
  const user = { email };
  await AsyncStorage.setItem(AUTH_USER_KEY, JSON.stringify(user));
  return user;
}

export async function logout(): Promise<void> {
  await AsyncStorage.removeItem(AUTH_USER_KEY);
}

export async function getLoggedInUser(): Promise<User | null> {
  const data = await AsyncStorage.getItem(AUTH_USER_KEY);
  if (data) {
    return JSON.parse(data);
  }
  return null;
}
