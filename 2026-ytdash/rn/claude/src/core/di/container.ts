import { AuthRemoteDataSource, AuthRemoteDataSourceImpl } from '@/src/features/authentication/data/datasources/auth-remote-datasource';
import { AuthRepositoryImpl } from '@/src/features/authentication/data/repositories/auth-repository-impl';
import { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';
import { SignInWithGoogle } from '@/src/features/authentication/domain/usecases/sign-in-with-google';
import { SignOut } from '@/src/features/authentication/domain/usecases/sign-out';
import { GetCurrentUser } from '@/src/features/authentication/domain/usecases/get-current-user';
import { VideosRemoteDataSource, VideosRemoteDataSourceImpl } from '@/src/features/videos/data/datasources/videos-remote-datasource';
import { VideosLocalDataSource, VideosLocalDataSourceImpl } from '@/src/features/videos/data/datasources/videos-local-datasource';
import { VideosRepositoryImpl } from '@/src/features/videos/data/repositories/videos-repository-impl';
import { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';
import { GetVideos } from '@/src/features/videos/domain/usecases/get-videos';
import { GetVideosByChannel } from '@/src/features/videos/domain/usecases/get-videos-by-channel';
import { GetVideosByCountry } from '@/src/features/videos/domain/usecases/get-videos-by-country';

export interface Container {
  authRemoteDataSource: AuthRemoteDataSource;
  authRepository: AuthRepository;
  signInWithGoogle: SignInWithGoogle;
  signOut: SignOut;
  getCurrentUser: GetCurrentUser;
  videosRemoteDataSource: VideosRemoteDataSource;
  videosLocalDataSource: VideosLocalDataSource;
  videosRepository: VideosRepository;
  getVideos: GetVideos;
  getVideosByChannel: GetVideosByChannel;
  getVideosByCountry: GetVideosByCountry;
}

let _container: Container | null = null;

export function initContainer(): void {
  if (_container) return;

  const authRemoteDataSource = new AuthRemoteDataSourceImpl();
  const authRepository = new AuthRepositoryImpl(authRemoteDataSource);
  const signInWithGoogle = new SignInWithGoogle(authRepository);
  const signOut = new SignOut(authRepository);
  const getCurrentUser = new GetCurrentUser(authRepository);

  const videosRemoteDataSource = new VideosRemoteDataSourceImpl();
  const videosLocalDataSource = new VideosLocalDataSourceImpl();
  const videosRepository = new VideosRepositoryImpl(videosRemoteDataSource, videosLocalDataSource);
  const getVideos = new GetVideos(videosRepository);
  const getVideosByChannel = new GetVideosByChannel(videosRepository);
  const getVideosByCountry = new GetVideosByCountry(videosRepository);

  _container = {
    authRemoteDataSource,
    authRepository,
    signInWithGoogle,
    signOut,
    getCurrentUser,
    videosRemoteDataSource,
    videosLocalDataSource,
    videosRepository,
    getVideos,
    getVideosByChannel,
    getVideosByCountry,
  };
}

export const container: Container = new Proxy({} as Container, {
  get(_target, prop: string) {
    if (!_container) {
      throw new Error('Container not initialized. Call initContainer() first.');
    }
    return (_container as Record<string, unknown>)[prop];
  },
});
