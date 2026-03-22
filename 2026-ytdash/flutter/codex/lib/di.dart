import 'package:firebase_auth/firebase_auth.dart';
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
import 'features/videos/domain/repositories/videos_repository.dart';
import 'features/videos/domain/usecases/clear_cache.dart';
import 'features/videos/domain/usecases/get_videos.dart';
import 'features/videos/domain/usecases/get_videos_by_channel.dart';
import 'features/videos/domain/usecases/get_videos_by_country.dart';
import 'features/videos/presentation/bloc/videos_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<AuthBloc>()) {
    return;
  }

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(scopes: const ['email']),
  );
  getIt.registerLazySingleton<http.Client>(http.Client.new);

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );
  getIt.registerFactory(() => SignInWithGoogle(getIt<AuthRepository>()));
  getIt.registerFactory(() => SignOut(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerFactory(
    () => AuthBloc(
      signInWithGoogle: getIt<SignInWithGoogle>(),
      signOut: getIt<SignOut>(),
      getCurrentUser: getIt<GetCurrentUser>(),
    ),
  );

  getIt.registerLazySingleton<VideosRemoteDataSource>(
    () => VideosRemoteDataSourceImpl(client: getIt<http.Client>()),
  );
  getIt.registerLazySingleton<VideosLocalDataSource>(
    VideosLocalDataSourceImpl.new,
  );
  getIt.registerLazySingleton<VideosRepository>(
    () => VideosRepositoryImpl(
      remoteDataSource: getIt<VideosRemoteDataSource>(),
      localDataSource: getIt<VideosLocalDataSource>(),
    ),
  );
  getIt.registerFactory(() => GetVideos(getIt<VideosRepository>()));
  getIt.registerFactory(() => GetVideosByChannel(getIt<VideosRepository>()));
  getIt.registerFactory(() => GetVideosByCountry(getIt<VideosRepository>()));
  getIt.registerFactory(() => ClearCache(getIt<VideosRepository>()));
  getIt.registerFactory(
    () => VideosBloc(
      getVideos: getIt<GetVideos>(),
      getVideosByChannel: getIt<GetVideosByChannel>(),
      getVideosByCountry: getIt<GetVideosByCountry>(),
      clearCache: getIt<ClearCache>(),
    ),
  );
}
