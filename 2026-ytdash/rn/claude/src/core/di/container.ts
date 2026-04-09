import {
  AuthRemoteDataSource,
  AuthRemoteDataSourceImpl,
} from '../../features/authentication/data/datasources/auth-remote-datasource';
import { AuthRepositoryImpl } from '../../features/authentication/data/repositories/auth-repository-impl';
import { AuthRepository } from '../../features/authentication/domain/repositories/auth-repository';
import { GetCurrentUser } from '../../features/authentication/domain/usecases/get-current-user';
import { SignInWithGoogle } from '../../features/authentication/domain/usecases/sign-in-with-google';
import { SignOut } from '../../features/authentication/domain/usecases/sign-out';
import {
  VideosRemoteDataSource,
  VideosRemoteDataSourceImpl,
} from '../../features/videos/data/datasources/videos-remote-datasource';
import {
  VideosLocalDataSource,
  VideosLocalDataSourceImpl,
} from '../../features/videos/data/datasources/videos-local-datasource';
import { VideosRepositoryImpl } from '../../features/videos/data/repositories/videos-repository-impl';
import { VideosRepository } from '../../features/videos/domain/repositories/videos-repository';
import { GetVideos } from '../../features/videos/domain/usecases/get-videos';
import { GetVideosByChannel } from '../../features/videos/domain/usecases/get-videos-by-channel';
import { GetVideosByCountry } from '../../features/videos/domain/usecases/get-videos-by-country';

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
