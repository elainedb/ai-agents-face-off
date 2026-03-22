// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

import 'di.dart' as _i913;
import 'features/authentication/data/datasources/auth_remote_data_source.dart'
    as _i990;
import 'features/authentication/data/repositories/auth_repository_impl.dart'
    as _i446;
import 'features/authentication/domain/repositories/auth_repository.dart'
    as _i877;
import 'features/authentication/domain/usecases/get_current_user.dart' as _i666;
import 'features/authentication/domain/usecases/sign_in_with_google.dart'
    as _i123;
import 'features/authentication/domain/usecases/sign_out.dart' as _i484;
import 'features/authentication/presentation/bloc/auth_bloc.dart' as _i706;
import 'features/videos/data/datasources/videos_local_data_source.dart'
    as _i618;
import 'features/videos/data/datasources/videos_remote_data_source.dart'
    as _i529;
import 'features/videos/data/repositories/videos_repository_impl.dart' as _i270;
import 'features/videos/domain/repositories/videos_repository.dart' as _i197;
import 'features/videos/domain/usecases/videos_usecases.dart' as _i44;
import 'features/videos/presentation/bloc/videos_bloc.dart' as _i844;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.singleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.singleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i618.VideosLocalDataSource>(
      () => _i618.VideosLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i990.AuthRemoteDataSource>(
      () => _i990.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i529.VideosRemoteDataSource>(
      () => _i529.VideosRemoteDataSourceImpl(gh<_i519.Client>()),
    );
    gh.lazySingleton<_i877.AuthRepository>(
      () => _i446.AuthRepositoryImpl(gh<_i990.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i197.VideosRepository>(
      () => _i270.VideosRepositoryImpl(
        remoteDataSource: gh<_i529.VideosRemoteDataSource>(),
        localDataSource: gh<_i618.VideosLocalDataSource>(),
      ),
    );
    gh.factory<_i666.GetCurrentUser>(
      () => _i666.GetCurrentUser(gh<_i877.AuthRepository>()),
    );
    gh.factory<_i123.SignInWithGoogle>(
      () => _i123.SignInWithGoogle(gh<_i877.AuthRepository>()),
    );
    gh.factory<_i484.SignOut>(() => _i484.SignOut(gh<_i877.AuthRepository>()));
    gh.factory<_i44.GetVideos>(
      () => _i44.GetVideos(gh<_i197.VideosRepository>()),
    );
    gh.factory<_i44.GetVideosByChannel>(
      () => _i44.GetVideosByChannel(gh<_i197.VideosRepository>()),
    );
    gh.factory<_i44.GetVideosByCountry>(
      () => _i44.GetVideosByCountry(gh<_i197.VideosRepository>()),
    );
    gh.factory<_i706.AuthBloc>(
      () => _i706.AuthBloc(
        getCurrentUser: gh<_i666.GetCurrentUser>(),
        signInWithGoogle: gh<_i123.SignInWithGoogle>(),
        signOut: gh<_i484.SignOut>(),
      ),
    );
    gh.factory<_i844.VideosBloc>(() => _i844.VideosBloc(gh<_i44.GetVideos>()));
    return this;
  }
}

class _$RegisterModule extends _i913.RegisterModule {}
