import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/get_current_user.dart';
import '../features/authentication/domain/usecases/sign_in_with_google.dart';
import '../features/authentication/domain/usecases/sign_out.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';
import '../features/videos/data/datasources/geocoding_service.dart';
import '../features/videos/data/datasources/videos_local_data_source.dart';
import '../features/videos/data/datasources/videos_remote_data_source.dart';
import '../features/videos/data/repositories/videos_repository_impl.dart';
import '../features/videos/domain/repositories/videos_repository.dart';
import '../features/videos/domain/usecases/get_videos.dart';
import '../features/videos/domain/usecases/get_videos_by_channel.dart';
import '../features/videos/domain/usecases/get_videos_by_country.dart';
import '../features/videos/presentation/bloc/videos_bloc.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<AuthBloc>()) {
    return;
  }

  getIt
    ..registerLazySingleton<firebase_auth.FirebaseAuth>(
      () => firebase_auth.FirebaseAuth.instance,
    )
    ..registerLazySingleton<GoogleSignIn>(
      () => GoogleSignIn(scopes: const ['email']),
    )
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: getIt(),
        googleSignIn: getIt(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerFactory(() => SignInWithGoogle(getIt()))
    ..registerFactory(() => SignOut(getIt()))
    ..registerFactory(() => GetCurrentUser(getIt()))
    ..registerFactory(
      () => AuthBloc(
        signInWithGoogle: getIt(),
        signOut: getIt(),
        getCurrentUser: getIt(),
      ),
    )
    ..registerLazySingleton(() => GeocodingService(client: getIt()))
    ..registerLazySingleton<VideosRemoteDataSource>(
      () => VideosRemoteDataSourceImpl(
        client: getIt(),
        geocodingService: getIt(),
      ),
    )
    ..registerLazySingleton<VideosLocalDataSource>(
      VideosLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<VideosRepository>(
      () => VideosRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
      ),
    )
    ..registerFactory(() => GetVideos(getIt()))
    ..registerFactory(() => GetVideosByChannel(getIt()))
    ..registerFactory(() => GetVideosByCountry(getIt()))
    ..registerFactory(
      () => VideosBloc(
        getVideos: getIt(),
        getVideosByChannel: getIt(),
        getVideosByCountry: getIt(),
      ),
    );
}
