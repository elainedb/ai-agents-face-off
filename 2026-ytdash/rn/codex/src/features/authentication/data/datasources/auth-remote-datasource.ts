import { GoogleSignin, isErrorWithCode, statusCodes } from '@react-native-google-signin/google-signin';
import { Platform } from 'react-native';

import { AuthException, NetworkException } from '@/src/core/error/exceptions';
import { UserModel } from '@/src/features/authentication/data/models/user-model';

export class AuthRemoteDataSource {
  constructor() {
    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });
  }

  async signInWithGoogle(): Promise<UserModel> {
    try {
      if (Platform.OS !== 'android') {
        throw new AuthException('Google Sign-In is only enabled for Android in this build.');
      }

      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      const response = await GoogleSignin.signIn();
      if (!response.data?.user) {
        throw new AuthException('Google Sign-In did not return a user profile.');
      }

      return UserModel.fromGoogleUser(response.data.user);
    } catch (error) {
      if (isErrorWithCode(error)) {
        if (error.code === statusCodes.SIGN_IN_CANCELLED) {
          throw new AuthException('Sign-in was cancelled.');
        }

        if (error.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
          throw new NetworkException('Google Play Services are not available on this device.');
        }

        if (error.code === statusCodes.IN_PROGRESS) {
          throw new AuthException('Google Sign-In is already in progress.');
        }
      }

      if (error instanceof Error) {
        throw new AuthException(error.message);
      }

      throw new AuthException('Unable to sign in with Google.');
    }
  }

  async signOut(): Promise<void> {
    await GoogleSignin.signOut();
  }

  async getCurrentUser(): Promise<UserModel | null> {
    const currentUser = GoogleSignin.getCurrentUser();
    if (!currentUser?.user) {
      return null;
    }

    return UserModel.fromGoogleUser(currentUser.user);
  }
}
