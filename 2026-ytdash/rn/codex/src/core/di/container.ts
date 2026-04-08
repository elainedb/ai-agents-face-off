import { AuthRemoteDataSource } from '@/src/features/authentication/data/datasources/auth-remote-datasource';
import { AuthRepositoryImpl } from '@/src/features/authentication/data/repositories/auth-repository-impl';
import { createAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';
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
import { createVideosStore } from '@/src/features/videos/presentation/stores/videos-store';

export interface Container {
  authRemoteDataSource: AuthRemoteDataSource;
  authRepository: AuthRepositoryImpl;
  signInWithGoogle: SignInWithGoogle;
  signOut: SignOut;
  getCurrentUser: GetCurrentUser;
  authStore: ReturnType<typeof createAuthStore>;
  videosRemoteDataSource: VideosRemoteDataSource;
  videosLocalDataSource: VideosLocalDataSource;
  videosRepository: VideosRepositoryImpl;
  getVideos: GetVideos;
  getVideosByChannel: GetVideosByChannel;
  getVideosByCountry: GetVideosByCountry;
  videosStore: ReturnType<typeof createVideosStore>;
}

let container: Container | null = null;

export const initContainer = (): Container => {
  if (container) {
    return container;
  }

  const authRemoteDataSource = new AuthRemoteDataSource();
  const authRepository = new AuthRepositoryImpl(authRemoteDataSource);
  const signInWithGoogle = new SignInWithGoogle(authRepository);
  const signOut = new SignOut(authRepository);
  const getCurrentUser = new GetCurrentUser(authRepository);

  const geocodingService = new GeocodingService();
  const videosRemoteDataSource = new VideosRemoteDataSource(geocodingService);
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
    authStore: createAuthStore({ getCurrentUser, signInWithGoogle, signOutUseCase: signOut }),
    videosRemoteDataSource,
    videosLocalDataSource,
    videosRepository,
    getVideos,
    getVideosByChannel,
    getVideosByCountry,
    videosStore: createVideosStore({ getVideos }),
  };

  return container;
};

export const getContainer = (): Container => initContainer();
