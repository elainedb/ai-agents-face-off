import { AuthRemoteDataSource } from '@/src/features/authentication/data/datasources/auth-remote-datasource';
import { AuthRepositoryImpl } from '@/src/features/authentication/data/repositories/auth-repository-impl';
import { SignInWithGoogle } from '@/src/features/authentication/domain/usecases/sign-in-with-google';
import { SignOut } from '@/src/features/authentication/domain/usecases/sign-out';
import { GetCurrentUser } from '@/src/features/authentication/domain/usecases/get-current-user';
import { VideosRemoteDataSource } from '@/src/features/videos/data/datasources/videos-remote-datasource';
import { VideosLocalDataSource } from '@/src/features/videos/data/datasources/videos-local-datasource';
import { VideosRepositoryImpl } from '@/src/features/videos/data/repositories/videos-repository-impl';
import { GetVideos } from '@/src/features/videos/domain/usecases/get-videos';
import { GetVideosByChannel } from '@/src/features/videos/domain/usecases/get-videos-by-channel';
import { GetVideosByCountry } from '@/src/features/videos/domain/usecases/get-videos-by-country';
import type { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';
import type { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';

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

let container: Container | null = null;

export function initContainer(): Container {
  if (container) return container;

  const authRemoteDataSource = new AuthRemoteDataSource();
  const authRepository = new AuthRepositoryImpl(authRemoteDataSource);
  const signInWithGoogle = new SignInWithGoogle(authRepository);
  const signOut = new SignOut(authRepository);
  const getCurrentUser = new GetCurrentUser(authRepository);

  const videosRemoteDataSource = new VideosRemoteDataSource();
  const videosLocalDataSource = new VideosLocalDataSource();
  const videosRepository = new VideosRepositoryImpl(videosRemoteDataSource, videosLocalDataSource);
  const getVideos = new GetVideos(videosRepository);
  const getVideosByChannel = new GetVideosByChannel(videosRepository);
  const getVideosByCountry = new GetVideosByCountry(videosRepository);

  container = {
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

  return container;
}

export function getContainer(): Container {
  if (!container) {
    throw new Error('Container not initialized. Call initContainer() first.');
  }
  return container;
}
