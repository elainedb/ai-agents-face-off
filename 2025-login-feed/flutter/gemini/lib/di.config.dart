// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sqflite/sqflite.dart' as _i779;

import 'core/services/api_key_service.dart' as _i803;
import 'core/services/reverse_geocoding_service.dart' as _i130;
import 'features/login/data/datasources/auth_local_data_source.dart' as _i406;
import 'features/login/data/datasources/login_remote_data_source.dart' as _i18;
import 'features/login/data/repositories/auth_repository_impl.dart' as _i606;
import 'features/login/data/repositories/login_repository_impl.dart' as _i1059;
import 'features/login/domain/repositories/auth_repository.dart' as _i590;
import 'features/login/domain/repositories/login_repository.dart' as _i889;
import 'features/login/domain/usecases/is_email_authorized.dart' as _i976;
import 'features/login/domain/usecases/login_with_google.dart' as _i743;
import 'features/login/presentation/bloc/login_bloc.dart' as _i1070;
import 'features/video/data/datasources/video_local_data_source.dart' as _i242;
import 'features/video/data/datasources/video_local_data_source_impl.dart'
    as _i411;
import 'features/video/data/datasources/video_remote_data_source.dart' as _i577;
import 'features/video/data/datasources/video_remote_data_source_impl.dart'
    as _i93;
import 'features/video/data/repositories/video_repository_impl.dart' as _i23;
import 'features/video/domain/repositories/video_repository.dart' as _i454;
import 'features/video/domain/usecases/get_videos.dart' as _i433;
import 'features/video/presentation/bloc/video_bloc.dart' as _i589;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  await gh.singletonAsync<_i779.Database>(
    () => registerModule.database,
    preResolve: true,
  );
  gh.lazySingleton<_i130.ReverseGeocodingService>(
    () => _i130.ReverseGeocodingService(),
  );
  gh.lazySingleton<_i803.ApiKeyService>(() => _i803.ApiKeyService());
  gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
  gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
  gh.lazySingleton<_i242.VideoLocalDataSource>(
    () => _i411.VideoLocalDataSourceImpl(gh<_i779.Database>()),
  );
  gh.lazySingleton<_i577.VideoRemoteDataSource>(
    () => _i93.VideoRemoteDataSourceImpl(
      gh<_i361.Dio>(),
      gh<_i803.ApiKeyService>(),
      gh<_i130.ReverseGeocodingService>(),
    ),
  );
  gh.lazySingleton<_i18.LoginRemoteDataSource>(
    () => _i18.LoginRemoteDataSourceImpl(gh<_i116.GoogleSignIn>()),
  );
  gh.lazySingleton<_i406.AuthLocalDataSource>(
    () => _i406.AuthLocalDataSourceImpl(),
  );
  gh.lazySingleton<_i454.VideoRepository>(
    () => _i23.VideoRepositoryImpl(
      gh<_i577.VideoRemoteDataSource>(),
      gh<_i242.VideoLocalDataSource>(),
    ),
  );
  gh.lazySingleton<_i889.LoginRepository>(
    () => _i1059.LoginRepositoryImpl(
      remoteDataSource: gh<_i18.LoginRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i590.AuthRepository>(
    () => _i606.AuthRepositoryImpl(
      localDataSource: gh<_i406.AuthLocalDataSource>(),
    ),
  );
  gh.factory<_i433.GetVideos>(
    () => _i433.GetVideos(gh<_i454.VideoRepository>()),
  );
  gh.factory<_i589.VideoBloc>(() => _i589.VideoBloc(gh<_i433.GetVideos>()));
  gh.factory<_i743.LoginWithGoogle>(
    () => _i743.LoginWithGoogle(gh<_i889.LoginRepository>()),
  );
  gh.factory<_i976.IsEmailAuthorized>(
    () => _i976.IsEmailAuthorized(gh<_i590.AuthRepository>()),
  );
  gh.factory<_i1070.LoginBloc>(
    () => _i1070.LoginBloc(
      gh<_i743.LoginWithGoogle>(),
      gh<_i976.IsEmailAuthorized>(),
      gh<_i116.GoogleSignIn>(),
    ),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
