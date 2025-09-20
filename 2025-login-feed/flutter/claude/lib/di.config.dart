// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:flutter_claude/di.dart' as _i888;
import 'package:flutter_claude/features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i1020;
import 'package:flutter_claude/features/authentication/data/repositories/auth_repository_impl.dart'
    as _i547;
import 'package:flutter_claude/features/authentication/domain/repositories/auth_repository.dart'
    as _i246;
import 'package:flutter_claude/features/authentication/domain/usecases/get_current_user.dart'
    as _i98;
import 'package:flutter_claude/features/authentication/domain/usecases/sign_in_with_google.dart'
    as _i178;
import 'package:flutter_claude/features/authentication/domain/usecases/sign_out.dart'
    as _i987;
import 'package:flutter_claude/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i810;
import 'package:flutter_claude/features/videos/data/datasources/videos_local_datasource.dart'
    as _i415;
import 'package:flutter_claude/features/videos/data/datasources/videos_remote_datasource.dart'
    as _i529;
import 'package:flutter_claude/features/videos/data/repositories/videos_repository_impl.dart'
    as _i845;
import 'package:flutter_claude/features/videos/domain/repositories/videos_repository.dart'
    as _i274;
import 'package:flutter_claude/features/videos/domain/usecases/get_videos.dart'
    as _i585;
import 'package:flutter_claude/features/videos/domain/usecases/get_videos_by_channel.dart'
    as _i383;
import 'package:flutter_claude/features/videos/domain/usecases/get_videos_by_country.dart'
    as _i4;
import 'package:flutter_claude/features/videos/presentation/bloc/videos_bloc.dart'
    as _i354;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

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
    gh.lazySingleton<_i415.VideosLocalDataSource>(
      () => _i415.VideosLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i1020.AuthRemoteDataSource>(
      () => _i1020.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i529.VideosRemoteDataSource>(
      () => _i529.VideosRemoteDataSourceImpl(client: gh<_i519.Client>()),
    );
    gh.lazySingleton<_i274.VideosRepository>(
      () => _i845.VideosRepositoryImpl(
        remoteDataSource: gh<_i529.VideosRemoteDataSource>(),
        localDataSource: gh<_i415.VideosLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i246.AuthRepository>(
      () => _i547.AuthRepositoryImpl(gh<_i1020.AuthRemoteDataSource>()),
    );
    gh.factory<_i4.GetVideosByCountry>(
      () => _i4.GetVideosByCountry(gh<_i274.VideosRepository>()),
    );
    gh.factory<_i585.GetVideos>(
      () => _i585.GetVideos(gh<_i274.VideosRepository>()),
    );
    gh.factory<_i383.GetVideosByChannel>(
      () => _i383.GetVideosByChannel(gh<_i274.VideosRepository>()),
    );
    gh.factory<_i987.SignOut>(() => _i987.SignOut(gh<_i246.AuthRepository>()));
    gh.factory<_i178.SignInWithGoogle>(
      () => _i178.SignInWithGoogle(gh<_i246.AuthRepository>()),
    );
    gh.factory<_i98.GetCurrentUser>(
      () => _i98.GetCurrentUser(gh<_i246.AuthRepository>()),
    );
    gh.factory<_i810.AuthBloc>(
      () => _i810.AuthBloc(
        gh<_i178.SignInWithGoogle>(),
        gh<_i987.SignOut>(),
        gh<_i98.GetCurrentUser>(),
      ),
    );
    gh.factory<_i354.VideosBloc>(
      () => _i354.VideosBloc(getVideos: gh<_i585.GetVideos>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i888.RegisterModule {}
