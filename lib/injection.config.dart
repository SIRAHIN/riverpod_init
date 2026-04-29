// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'api_service/auth_api_service.dart' as _i456;
import 'api_service/i_auth_api_service.dart' as _i1016;
import 'local_service/auth_local_service.dart' as _i141;
import 'provider/auth_state_notifer.dart' as _i243;
import 'repository/auth_respository.dart' as _i241;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.factory<_i243.AuthStateNotifer>(() => _i243.AuthStateNotifer());
  gh.lazySingleton<_i1016.AuthApiService>(() => _i456.IAuthApiService());
  gh.lazySingleton<_i241.AuthRepository>(() => _i241.IAuthRepository(
        gh<_i1016.AuthApiService>(),
        gh<_i141.AuthLocalService>(),
      ));
  return getIt;
}
