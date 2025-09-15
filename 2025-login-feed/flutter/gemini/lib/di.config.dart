// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

import 'features/login/data/datasources/login_remote_data_source.dart' as _i18;
import 'features/login/data/repositories/login_repository_impl.dart' as _i1059;
import 'features/login/domain/repositories/login_repository.dart' as _i889;
import 'features/login/domain/usecases/sign_in_with_google.dart' as _i259;
import 'features/login/domain/usecases/sign_out.dart' as _i278;
import 'features/login/presentation/bloc/login_bloc.dart' as _i1070;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
  gh.lazySingleton<_i18.LoginRemoteDataSource>(
    () => _i18.LoginRemoteDataSourceImpl(gh<_i116.GoogleSignIn>()),
  );
  gh.lazySingleton<_i889.LoginRepository>(
    () => _i1059.LoginRepositoryImpl(gh<_i18.LoginRemoteDataSource>()),
  );
  gh.factory<_i259.SignInWithGoogle>(
    () => _i259.SignInWithGoogle(gh<_i889.LoginRepository>()),
  );
  gh.factory<_i278.SignOut>(() => _i278.SignOut(gh<_i889.LoginRepository>()));
  gh.factory<_i1070.LoginBloc>(
    () => _i1070.LoginBloc(gh<_i259.SignInWithGoogle>(), gh<_i278.SignOut>()),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
