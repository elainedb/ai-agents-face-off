import {
  GoogleSignin,
  isSuccessResponse,
} from '@react-native-google-signin/google-signin';
import { AuthException } from '@/src/core/error/exceptions';
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
      webClientId: '83953880984-7n5mp2qaj2i9nqom6gohaqht00a88rbb.apps.googleusercontent.com',
    });
  }

  async signInWithGoogle(): Promise<UserModel> {
    try {
      await GoogleSignin.hasPlayServices();
      const response = await GoogleSignin.signIn();
      if (!isSuccessResponse(response)) {
        throw new AuthException('Google Sign-In was cancelled');
      }
      const { data } = response;
      const user = data.user;
      return UserModel.fromGoogleUser({
        id: user.id,
        name: user.name,
        email: user.email,
        photo: user.photo,
      });
    } catch (error) {
      if (error instanceof AuthException) throw error;
      throw new AuthException(
        error instanceof Error ? error.message : 'Google Sign-In failed',
      );
    }
  }

  async signOut(): Promise<void> {
    try {
      await GoogleSignin.signOut();
    } catch (error) {
      throw new AuthException(
        error instanceof Error ? error.message : 'Sign out failed',
      );
    }
  }

  async getCurrentUser(): Promise<UserModel | null> {
    try {
      const currentUser = await GoogleSignin.getCurrentUser();
      if (!currentUser) return null;
      const user = currentUser.user;
      return UserModel.fromGoogleUser({
        id: user.id,
        name: user.name,
        email: user.email,
        photo: user.photo,
      });
    } catch {
      return null;
    }
  }
}
