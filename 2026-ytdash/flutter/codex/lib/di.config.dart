// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

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
import 'package:ytdash_flutter_codex/di.dart' as _i180;
import 'package:ytdash_flutter_codex/features/authentication/data/datasources/auth_remote_data_source.dart'
    as _i34;
import 'package:ytdash_flutter_codex/features/authentication/data/repositories/auth_repository_impl.dart'
    as _i462;
import 'package:ytdash_flutter_codex/features/authentication/domain/repositories/auth_repository.dart'
    as _i207;
import 'package:ytdash_flutter_codex/features/authentication/domain/usecases/get_current_user.dart'
    as _i744;
import 'package:ytdash_flutter_codex/features/authentication/domain/usecases/sign_in_with_google.dart'
    as _i221;
import 'package:ytdash_flutter_codex/features/authentication/domain/usecases/sign_out.dart'
    as _i422;
import 'package:ytdash_flutter_codex/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i837;
import 'package:ytdash_flutter_codex/features/videos/data/datasources/videos_local_data_source.dart'
    as _i904;
import 'package:ytdash_flutter_codex/features/videos/data/datasources/videos_remote_data_source.dart'
    as _i512;
import 'package:ytdash_flutter_codex/features/videos/data/repositories/videos_repository_impl.dart'
    as _i573;
import 'package:ytdash_flutter_codex/features/videos/domain/repositories/videos_repository.dart'
    as _i373;
import 'package:ytdash_flutter_codex/features/videos/domain/usecases/get_videos.dart'
    as _i6;
import 'package:ytdash_flutter_codex/features/videos/domain/usecases/get_videos_by_channel.dart'
    as _i342;
import 'package:ytdash_flutter_codex/features/videos/domain/usecases/get_videos_by_country.dart'
    as _i520;
import 'package:ytdash_flutter_codex/features/videos/presentation/bloc/videos_bloc.dart'
    as _i344;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt $initGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i904.VideosLocalDataSource>(
      () => _i904.VideosLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i512.VideosRemoteDataSource>(
      () => _i512.VideosRemoteDataSourceImpl(gh<_i519.Client>()),
    );
    gh.lazySingleton<_i34.AuthRemoteDataSource>(
      () => _i34.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i373.VideosRepository>(
      () => _i573.VideosRepositoryImpl(
        gh<_i512.VideosRemoteDataSource>(),
        gh<_i904.VideosLocalDataSource>(),
      ),
    );
    gh.factory<_i520.GetVideosByCountry>(
      () => _i520.GetVideosByCountry(gh<_i373.VideosRepository>()),
    );
    gh.factory<_i6.GetVideos>(
      () => _i6.GetVideos(gh<_i373.VideosRepository>()),
    );
    gh.factory<_i342.GetVideosByChannel>(
      () => _i342.GetVideosByChannel(gh<_i373.VideosRepository>()),
    );
    gh.lazySingleton<_i207.AuthRepository>(
      () => _i462.AuthRepositoryImpl(gh<_i34.AuthRemoteDataSource>()),
    );
    gh.factory<_i344.VideosBloc>(() => _i344.VideosBloc(gh<_i6.GetVideos>()));
    gh.factory<_i422.SignOut>(() => _i422.SignOut(gh<_i207.AuthRepository>()));
    gh.factory<_i221.SignInWithGoogle>(
      () => _i221.SignInWithGoogle(gh<_i207.AuthRepository>()),
    );
    gh.factory<_i744.GetCurrentUser>(
      () => _i744.GetCurrentUser(gh<_i207.AuthRepository>()),
    );
    gh.factory<_i837.AuthBloc>(
      () => _i837.AuthBloc(
        gh<_i221.SignInWithGoogle>(),
        gh<_i422.SignOut>(),
        gh<_i744.GetCurrentUser>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i180.RegisterModule {}
