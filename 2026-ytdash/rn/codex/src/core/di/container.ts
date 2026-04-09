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

export interface Container {
  authRemoteDataSource: AuthRemoteDataSource;
  authRepository: AuthRepositoryImpl;
  signInWithGoogle: SignInWithGoogle;
  signOut: SignOut;
  getCurrentUser: GetCurrentUser;
  geocodingService: GeocodingService;
  videosRemoteDataSource: VideosRemoteDataSource;
  videosLocalDataSource: VideosLocalDataSource;
  videosRepository: VideosRepositoryImpl;
  getVideos: GetVideos;
  getVideosByChannel: GetVideosByChannel;
  getVideosByCountry: GetVideosByCountry;
}

let container: Container | null = null;

export const initContainer = async (): Promise<Container> => {
  if (container) {
    return container;
  }

  const authRemoteDataSource = new AuthRemoteDataSource();
  const authRepository = new AuthRepositoryImpl(authRemoteDataSource);
  const geocodingService = new GeocodingService();
  const videosLocalDataSource = new VideosLocalDataSource();
  const videosRemoteDataSource = new VideosRemoteDataSource(geocodingService);
  const videosRepository = new VideosRepositoryImpl(videosRemoteDataSource, videosLocalDataSource);

  container = {
    authRemoteDataSource,
    authRepository,
    signInWithGoogle: new SignInWithGoogle(authRepository),
    signOut: new SignOut(authRepository),
    getCurrentUser: new GetCurrentUser(authRepository),
    geocodingService,
    videosRemoteDataSource,
    videosLocalDataSource,
    videosRepository,
    getVideos: new GetVideos(videosRepository),
    getVideosByChannel: new GetVideosByChannel(videosRepository),
    getVideosByCountry: new GetVideosByCountry(videosRepository),
  };

  return container;
};

export const getContainer = (): Container => {
  if (!container) {
    throw new Error('Container has not been initialized.');
  }

  return container;
};
