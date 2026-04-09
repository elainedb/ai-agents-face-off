import {
  GoogleSignin,
  statusCodes,
} from '@react-native-google-signin/google-signin';
import { AuthException } from '../../../../core/error/exceptions';
import { UserModel } from '../models/user-model';

export interface AuthRemoteDataSource {
  signInWithGoogle(): Promise<UserModel>;
  signOut(): Promise<void>;
  getCurrentUser(): Promise<UserModel | null>;
}

export class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  constructor() {
    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
      offlineAccess: false,
    });
  }

  async signInWithGoogle(): Promise<UserModel> {
    try {
      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      const response = await GoogleSignin.signIn();
      const userInfo = response.data;
      if (!userInfo?.user) {
        throw new AuthException('Google Sign-In failed: no user data returned');
      }
      return UserModel.fromGoogleUser(userInfo.user);
    } catch (error: unknown) {
      if (error instanceof AuthException) throw error;
      const typedError = error as { code?: string };
      if (typedError.code === statusCodes.SIGN_IN_CANCELLED) {
        throw new AuthException('Sign-in was cancelled');
      }
      if (typedError.code === statusCodes.IN_PROGRESS) {
        throw new AuthException('Sign-in is already in progress');
      }
      if (typedError.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        throw new AuthException('Google Play Services not available');
      }
      throw new AuthException(
        `Google Sign-In failed: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async signOut(): Promise<void> {
    try {
      await GoogleSignin.signOut();
    } catch (error: unknown) {
      throw new AuthException(
        `Sign-out failed: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async getCurrentUser(): Promise<UserModel | null> {
    try {
      const currentUser = await GoogleSignin.getCurrentUser();
      if (!currentUser?.user) return null;
      return UserModel.fromGoogleUser(currentUser.user);
    } catch {
      return null;
    }
  }
}
