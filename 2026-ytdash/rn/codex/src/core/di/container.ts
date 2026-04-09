import * as SQLite from 'expo-sqlite';

import { AuthRemoteDataSource } from '@/src/features/authentication/data/datasources/auth-remote-datasource';
import { AuthRepositoryImpl } from '@/src/features/authentication/data/repositories/auth-repository-impl';
import { GetCurrentUser } from '@/src/features/authentication/domain/usecases/get-current-user';
import { SignInWithGoogle } from '@/src/features/authentication/domain/usecases/sign-in-with-google';
import { SignOut } from '@/src/features/authentication/domain/usecases/sign-out';
import { VideosLocalDataSource } from '@/src/features/videos/data/datasources/videos-local-datasource';
import { VideosRemoteDataSource } from '@/src/features/videos/data/datasources/videos-remote-datasource';
import { VideosRepositoryImpl } from '@/src/features/videos/data/repositories/videos-repository-impl';
import { GeocodingService } from '@/src/features/videos/data/services/geocoding-service';
import { GetVideos } from '@/src/features/videos/domain/usecases/get-videos';
import { GetVideosByChannel } from '@/src/features/videos/domain/usecases/get-videos-by-channel';
import { GetVideosByCountry } from '@/src/features/videos/domain/usecases/get-videos-by-country';

export interface AuthContainer {
  authRemoteDataSource: AuthRemoteDataSource;
  authRepository: AuthRepositoryImpl;
  signInWithGoogle: SignInWithGoogle;
  signOut: SignOut;
  getCurrentUser: GetCurrentUser;
}

export interface VideosContainer {
  videosRemoteDataSource: VideosRemoteDataSource;
  videosLocalDataSource: VideosLocalDataSource;
  videosRepository: VideosRepositoryImpl;
  getVideos: GetVideos;
  getVideosByChannel: GetVideosByChannel;
  getVideosByCountry: GetVideosByCountry;
}

export interface Container extends AuthContainer, VideosContainer {}

let authContainer: AuthContainer | null = null;
let authContainerPromise: Promise<AuthContainer> | null = null;
let videosContainer: VideosContainer | null = null;
let videosContainerPromise: Promise<VideosContainer> | null = null;

export async function initAuthContainer(): Promise<AuthContainer> {
  if (authContainer) {
    return authContainer;
  }

  if (authContainerPromise) {
    return authContainerPromise;
  }

  authContainerPromise = Promise.resolve().then(() => {
    const authRemoteDataSource = new AuthRemoteDataSource();
    const authRepository = new AuthRepositoryImpl(authRemoteDataSource);

    authContainer = {
      authRemoteDataSource,
      authRepository,
      signInWithGoogle: new SignInWithGoogle(authRepository),
      signOut: new SignOut(authRepository),
      getCurrentUser: new GetCurrentUser(authRepository),
    };

    return authContainer;
  });

  try {
    return await authContainerPromise;
  } catch (error) {
    authContainerPromise = null;
    throw error;
  }
}

export async function initVideosContainer(): Promise<VideosContainer> {
  if (videosContainer) {
    return videosContainer;
  }

  if (videosContainerPromise) {
    return videosContainerPromise;
  }

  videosContainerPromise = (async () => {
    const geocodingService = new GeocodingService();
    const videosRemoteDataSource = new VideosRemoteDataSource(geocodingService);
    const videosDatabase = await SQLite.openDatabaseAsync('videos.db');
    const videosLocalDataSource = new VideosLocalDataSource(videosDatabase);
    await videosLocalDataSource.init();
    const videosRepository = new VideosRepositoryImpl(videosRemoteDataSource, videosLocalDataSource);

    videosContainer = {
      videosRemoteDataSource,
      videosLocalDataSource,
      videosRepository,
      getVideos: new GetVideos(videosRepository),
      getVideosByChannel: new GetVideosByChannel(videosRepository),
      getVideosByCountry: new GetVideosByCountry(videosRepository),
    };

    return videosContainer;
  })();

  try {
    return await videosContainerPromise;
  } catch (error) {
    videosContainerPromise = null;
    throw error;
  }
}

export async function initContainer(): Promise<Container> {
  const [auth, videos] = await Promise.all([initAuthContainer(), initVideosContainer()]);
  return {
    ...auth,
    ...videos,
  };
}
