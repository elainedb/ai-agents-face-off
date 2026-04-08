import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { AuthException } from '@/src/core/error/exceptions';
import { UserModel } from '../models/user-model';

GoogleSignin.configure({
  scopes: ['openid', 'profile', 'email'],
});

export class AuthRemoteDataSource {
  async signInWithGoogle(): Promise<UserModel> {
    try {
      await GoogleSignin.hasPlayServices();
      const response = await GoogleSignin.signIn();
      const data = response.data;
      if (!data?.user) {
        throw new AuthException('Sign-in failed: no user data returned');
      }
      return UserModel.fromGoogleUser(data.user);
    } catch (error) {
      if (error instanceof AuthException) throw error;
      const message = error instanceof Error ? error.message : 'Unknown sign-in error';
      throw new AuthException(message);
    }
  }

  async signOut(): Promise<void> {
    try {
      await GoogleSignin.signOut();
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown sign-out error';
      throw new AuthException(message);
    }
  }

  async getCurrentUser(): Promise<UserModel | null> {
    try {
      const currentUser = await GoogleSignin.getCurrentUser();
      if (!currentUser?.data?.user) {
        return null;
      }
      return UserModel.fromGoogleUser(currentUser.data.user);
    } catch {
      return null;
    }
  }
}
