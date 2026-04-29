import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:riverpod_practice/api_service/i_auth_api_service.dart';
import 'package:riverpod_practice/local_service/auth_local_service.dart';
import 'package:riverpod_practice/models/auth_credential.dart';
import 'package:riverpod_practice/models/error_response.dart';
import 'package:riverpod_practice/models/login_response.dart';


abstract class AuthRepository {
  final AuthApiService authApiService;
  final AuthLocalService authLocalService;

  AuthRepository(this.authApiService, this.authLocalService);

  Future<Either<ErrorResponse, LoginResponse>> login(
      {required String userName, required String password});

  Future<void> saveCredentials({required String email, required String password});
  Future<AuthCredential?> getCredentials();
}

@LazySingleton(as: AuthRepository)
class IAuthRepository extends AuthRepository {
  IAuthRepository(super.authApiService, super.authLocalService);

  @override
  Future<Either<ErrorResponse, LoginResponse>> login(
      {required String userName, required String password}) {
    return authApiService.login(userName: userName, password: password);
  }
  
  @override
  Future<AuthCredential?> getCredentials() {
    return authLocalService.getUserCredential();
  }
  
  @override
  Future<void> saveCredentials({required String email, required String password}) {
    return authLocalService.setUserCredential(email: email, password: password);
  }
}
