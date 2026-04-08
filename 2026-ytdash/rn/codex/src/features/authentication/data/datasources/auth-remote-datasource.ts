import {
  GoogleSignin,
  isErrorWithCode,
  statusCodes,
  type User as GoogleUser,
} from '@react-native-google-signin/google-signin';
import { Platform } from 'react-native';

import {
  AuthException,
  NetworkException,
  ValidationException,
} from '@/src/core/error/exceptions';
import { UserModel } from '@/src/features/authentication/data/models/user-model';

export class AuthRemoteDataSource {
  private configured = false;

  configure(): void {
    if (this.configured) {
      return;
    }

    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });

    this.configured = true;
  }

  async signInWithGoogle(): Promise<UserModel> {
    this.configure();

    if (Platform.OS !== 'android') {
      throw new AuthException('Google Sign-In is configured for Android only.');
    }

    try {
      await GoogleSignin.hasPlayServices();
      const user = await GoogleSignin.signIn();
      return UserModel.fromGoogleUser(user as unknown as GoogleUser);
    } catch (error) {
      if (isErrorWithCode(error)) {
        if (
          error.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE ||
          error.code === statusCodes.SIGN_IN_CANCELLED
        ) {
          throw new AuthException(error.message);
        }
      }

      if (error instanceof Error) {
        throw new NetworkException(error.message);
      }

      throw new ValidationException('Unable to sign in with Google.');
    }
  }

  async signOut(): Promise<void> {
    this.configure();
    await GoogleSignin.signOut();
  }

  async getCurrentUser(): Promise<UserModel | null> {
    this.configure();
    const user = GoogleSignin.getCurrentUser();

    if (!user) {
      return null;
    }

    return UserModel.fromGoogleUser(user as GoogleUser);
  }
}
