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
import 'features/videos/domain/repositories/videos_repository.dart';
import 'features/videos/domain/usecases/clear_cache.dart';
import 'features/videos/domain/usecases/get_videos.dart';
import 'features/videos/domain/usecases/get_videos_by_channel.dart';
import 'features/videos/domain/usecases/get_videos_by_country.dart';
import 'features/videos/presentation/bloc/videos_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  await sl.reset();

  sl.registerLazySingleton<firebase_auth.FirebaseAuth>(
    () => firebase_auth.FirebaseAuth.instance,
  );
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      scopes: const [
        'email',
        'https://www.googleapis.com/auth/youtube.readonly',
      ],
    ),
  );
  sl.registerLazySingleton<http.Client>(http.Client.new);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => SignInWithGoogle(sl()));
  sl.registerFactory(() => SignOut(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
  sl.registerFactory(
    () => AuthBloc(signInWithGoogle: sl(), signOut: sl(), getCurrentUser: sl()),
  );

  sl.registerLazySingleton<VideosRemoteDataSource>(
    () => VideosRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<VideosLocalDataSource>(
    VideosLocalDataSourceImpl.new,
  );
  sl.registerLazySingleton<VideosRepository>(
    () => VideosRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerFactory(() => GetVideos(sl()));
  sl.registerFactory(() => GetVideosByChannel(sl()));
  sl.registerFactory(() => GetVideosByCountry(sl()));
  sl.registerFactory(() => ClearCache(sl()));
  sl.registerFactory(
    () => VideosBloc(
      getVideos: sl(),
      getVideosByChannel: sl(),
      getVideosByCountry: sl(),
      clearCache: sl(),
    ),
  );
}
