import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/videos/data/datasources/video_local_data_source.dart';
import '../../features/videos/data/datasources/youtube_remote_data_source.dart';
import '../../features/videos/data/repositories/video_repository_impl.dart';
import '../../features/videos/domain/repositories/video_repository.dart';
import '../../features/videos/presentation/bloc/video_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => GoogleSignIn(scopes: ['email']));

  // Data sources
  sl.registerLazySingleton(() => VideoLocalDataSource(sharedPreferences: sl()));
  sl.registerLazySingleton(() => YoutubeRemoteDataSource(client: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(googleSignIn: sl()),
  );
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // BLoCs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => VideoBloc(videoRepository: sl()));
}
