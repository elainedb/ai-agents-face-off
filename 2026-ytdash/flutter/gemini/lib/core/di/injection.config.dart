// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../data/datasources/video_local_data_source.dart' as _i30;
import '../../data/datasources/video_remote_data_source.dart' as _i313;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/video_repository_impl.dart' as _i516;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/repositories/video_repository.dart' as _i682;
import '../../presentation/bloc/auth/auth_bloc.dart' as _i605;
import '../../presentation/bloc/video/video_bloc.dart' as _i179;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i1073.AuthRepository>(() => _i895.AuthRepositoryImpl());
    gh.lazySingleton<_i30.VideoLocalDataSource>(
      () => _i30.VideoLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i605.AuthBloc>(
      () => _i605.AuthBloc(gh<_i1073.AuthRepository>()),
    );
    gh.lazySingleton<_i313.VideoRemoteDataSource>(
      () => _i313.VideoRemoteDataSourceImpl(gh<_i519.Client>()),
    );
    gh.lazySingleton<_i682.VideoRepository>(
      () => _i516.VideoRepositoryImpl(
        gh<_i313.VideoRemoteDataSource>(),
        gh<_i30.VideoLocalDataSource>(),
      ),
    );
    gh.factory<_i179.VideoBloc>(
      () => _i179.VideoBloc(gh<_i682.VideoRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
