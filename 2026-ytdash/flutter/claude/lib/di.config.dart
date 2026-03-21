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
import 'package:ytdash_flutter_claude/di.dart' as _i34;
import 'package:ytdash_flutter_claude/features/authentication/data/datasources/auth_remote_data_source.dart'
    as _i666;
import 'package:ytdash_flutter_claude/features/authentication/data/repositories/auth_repository_impl.dart'
    as _i185;
import 'package:ytdash_flutter_claude/features/authentication/domain/repositories/auth_repository.dart'
    as _i777;
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/get_current_user.dart'
    as _i422;
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_in_with_google.dart'
    as _i1058;
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_out.dart'
    as _i950;
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i62;
import 'package:ytdash_flutter_claude/features/videos/data/datasources/videos_local_data_source.dart'
    as _i642;
import 'package:ytdash_flutter_claude/features/videos/data/datasources/videos_remote_data_source.dart'
    as _i551;
import 'package:ytdash_flutter_claude/features/videos/data/repositories/videos_repository_impl.dart'
    as _i543;
import 'package:ytdash_flutter_claude/features/videos/domain/repositories/videos_repository.dart'
    as _i58;
import 'package:ytdash_flutter_claude/features/videos/domain/usecases/get_videos.dart'
    as _i71;
import 'package:ytdash_flutter_claude/features/videos/domain/usecases/get_videos_by_channel.dart'
    as _i755;
import 'package:ytdash_flutter_claude/features/videos/domain/usecases/get_videos_by_country.dart'
    as _i38;
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart'
    as _i14;

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
    gh.lazySingleton<_i666.AuthRemoteDataSource>(
      () => _i666.AuthRemoteDataSourceImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        googleSignIn: gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i642.VideosLocalDataSource>(
      () => _i642.VideosLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i551.VideosRemoteDataSource>(
      () => _i551.VideosRemoteDataSourceImpl(client: gh<_i519.Client>()),
    );
    gh.lazySingleton<_i777.AuthRepository>(
      () => _i185.AuthRepositoryImpl(
        remoteDataSource: gh<_i666.AuthRemoteDataSource>(),
      ),
    );
    gh.factory<_i422.GetCurrentUser>(
      () => _i422.GetCurrentUser(gh<_i777.AuthRepository>()),
    );
    gh.factory<_i1058.SignInWithGoogle>(
      () => _i1058.SignInWithGoogle(gh<_i777.AuthRepository>()),
    );
    gh.factory<_i950.SignOut>(() => _i950.SignOut(gh<_i777.AuthRepository>()));
    gh.lazySingleton<_i58.VideosRepository>(
      () => _i543.VideosRepositoryImpl(
        remoteDataSource: gh<_i551.VideosRemoteDataSource>(),
        localDataSource: gh<_i642.VideosLocalDataSource>(),
      ),
    );
    gh.factory<_i62.AuthBloc>(
      () => _i62.AuthBloc(
        signInWithGoogle: gh<_i1058.SignInWithGoogle>(),
        signOut: gh<_i950.SignOut>(),
        getCurrentUser: gh<_i422.GetCurrentUser>(),
      ),
    );
    gh.factory<_i71.GetVideos>(
      () => _i71.GetVideos(gh<_i58.VideosRepository>()),
    );
    gh.factory<_i755.GetVideosByChannel>(
      () => _i755.GetVideosByChannel(gh<_i58.VideosRepository>()),
    );
    gh.factory<_i38.GetVideosByCountry>(
      () => _i38.GetVideosByCountry(gh<_i58.VideosRepository>()),
    );
    gh.factory<_i14.VideosBloc>(
      () => _i14.VideosBloc(getVideos: gh<_i71.GetVideos>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i34.RegisterModule {}
