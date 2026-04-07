import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'features/authentication/data/datasources/auth_remote_data_source.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/get_current_user.dart';
import 'features/authentication/domain/usecases/sign_in_with_google.dart';
import 'features/authentication/domain/usecases/sign_out.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/videos/data/datasources/videos_local_data_source.dart';
import 'features/videos/data/datasources/videos_remote_data_source.dart';
import 'features/videos/data/repositories/videos_repository_impl.dart';
import 'features/videos/data/services/geocoding_service.dart';
import 'features/videos/domain/repositories/videos_repository.dart';
import 'features/videos/domain/usecases/clear_cache.dart';
import 'features/videos/domain/usecases/get_videos.dart';
import 'features/videos/domain/usecases/get_videos_by_channel.dart';
import 'features/videos/domain/usecases/get_videos_by_country.dart';
import 'features/videos/presentation/bloc/videos_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<http.Client>()) {
    return;
  }

  sl
    ..registerLazySingleton<firebase_auth.FirebaseAuth>(
      () => firebase_auth.FirebaseAuth.instance,
    )
    ..registerLazySingleton<GoogleSignIn>(
      () => GoogleSignIn(scopes: const <String>['email', 'profile']),
    )
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: sl<firebase_auth.FirebaseAuth>(),
        googleSignIn: sl<GoogleSignIn>(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
    )
    ..registerFactory(() => SignInWithGoogle(sl<AuthRepository>()))
    ..registerFactory(() => SignOut(sl<AuthRepository>()))
    ..registerFactory(() => GetCurrentUser(sl<AuthRepository>()))
    ..registerFactory(
      () => AuthBloc(
        getCurrentUser: sl<GetCurrentUser>(),
        signInWithGoogle: sl<SignInWithGoogle>(),
        signOut: sl<SignOut>(),
      ),
    )
    ..registerLazySingleton<GeocodingService>(
      () => GeocodingService(client: sl<http.Client>()),
    )
    ..registerLazySingleton<VideosLocalDataSource>(
      VideosLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<VideosRemoteDataSource>(
      () => VideosRemoteDataSourceImpl(
        client: sl<http.Client>(),
        geocodingService: sl<GeocodingService>(),
      ),
    )
    ..registerLazySingleton<VideosRepository>(
      () => VideosRepositoryImpl(
        localDataSource: sl<VideosLocalDataSource>(),
        remoteDataSource: sl<VideosRemoteDataSource>(),
      ),
    )
    ..registerFactory(() => GetVideos(sl<VideosRepository>()))
    ..registerFactory(() => GetVideosByChannel(sl<VideosRepository>()))
    ..registerFactory(() => GetVideosByCountry(sl<VideosRepository>()))
    ..registerFactory(() => ClearCache(sl<VideosRepository>()))
    ..registerFactory(
      () => VideosBloc(
        getVideos: sl<GetVideos>(),
        getVideosByChannel: sl<GetVideosByChannel>(),
        getVideosByCountry: sl<GetVideosByCountry>(),
        clearCache: sl<ClearCache>(),
      ),
    );
}

Future<void> resetDependencies() async {
  await sl.reset();
}
