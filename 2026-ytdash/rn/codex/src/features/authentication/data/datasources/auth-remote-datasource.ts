import {
  GoogleSignin,
  isErrorWithCode,
  statusCodes,
  type SignInResponse,
  type User as GoogleUser,
} from '@react-native-google-signin/google-signin';

import { AuthException } from '@/src/core/error/exceptions';
import { UserModel } from '@/src/features/authentication/data/models/user-model';

export class AuthRemoteDataSource {
  constructor() {
    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });
  }

  async signInWithGoogle(): Promise<UserModel> {
    try {
      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      const response = (await GoogleSignin.signIn()) as SignInResponse;

      if (response.type !== 'success') {
        throw new AuthException('Google sign-in was cancelled.');
      }

      return UserModel.fromGoogleUser(response.data as unknown as Record<string, unknown>);
    } catch (error) {
      if (isErrorWithCode(error)) {
        switch (error.code) {
          case statusCodes.SIGN_IN_CANCELLED:
            throw new AuthException('Google sign-in was cancelled.');
          case statusCodes.IN_PROGRESS:
            throw new AuthException('Google sign-in is already in progress.');
          case statusCodes.PLAY_SERVICES_NOT_AVAILABLE:
            throw new AuthException('Google Play Services are not available on this device.');
          default:
            throw new AuthException(error.message);
        }
      }

      throw new AuthException('Unable to sign in with Google.');
    }
  }

  async signOut(): Promise<void> {
    try {
      await GoogleSignin.signOut();
    } catch (error) {
      if (error instanceof Error) {
        throw new AuthException(error.message);
      }

      throw new AuthException('Unable to sign out.');
    }
  }

  async getCurrentUser(): Promise<UserModel | null> {
    const user = GoogleSignin.getCurrentUser() as GoogleUser | null;
    return user ? UserModel.fromGoogleUser(user as unknown as Record<string, unknown>) : null;
  }
}
