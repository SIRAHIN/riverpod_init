import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:riverpod_practice/api_service/i_auth_api_service.dart';
import 'package:riverpod_practice/models/error_response.dart';
import 'package:riverpod_practice/models/login_response.dart';


abstract class AuthRepository {
  final AuthApiService authApiService;

  AuthRepository(this.authApiService);

  Future<Either<ErrorResponse, LoginResponse>> login(
      {required String userName, required String password});
}

@LazySingleton(as: AuthRepository)
class IAuthRepository extends AuthRepository {
  IAuthRepository(super.authApiService);

  @override
  Future<Either<ErrorResponse, LoginResponse>> login(
      {required String userName, required String password}) {
    return authApiService.login(userName: userName, password: password);
  }
}
