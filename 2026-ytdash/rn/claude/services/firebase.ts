import firebase from '@react-native-firebase/app';
import auth, { FirebaseAuthTypes } from '@react-native-firebase/auth';

export { auth, firebase };
export type { FirebaseAuthTypes };

export function getCurrentUser(): FirebaseAuthTypes.User | null {
  return auth().currentUser;
}

export function onAuthStateChanged(
  callback: (user: FirebaseAuthTypes.User | null) => void
): () => void {
  return auth().onAuthStateChanged(callback);
}

export async function signOut(): Promise<void> {
  await auth().signOut();
}
