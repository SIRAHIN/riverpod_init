import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:riverpod_practice/api_service/auth_api_service.dart';
import 'package:riverpod_practice/repository/auth_respository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final apiService = ref.read(authApiServiceProvider);
  return IAuthRepository(apiService);
});

final authApiServiceProvider = Provider<IAuthApiService>((ref) {
  return IAuthApiService();
});

@injectable
class AuthStateNotifer extends AsyncNotifier<void> {
  late AuthRepository authRepository;
  AuthStateNotifer() : super();

  void login({required String userName, required String password}) async {
    // Implement login logic here
    state = AsyncLoading();
    // Simulate a login process
    final result =
        await authRepository.login(userName: userName, password: password);
    result.fold(
      (l) => state = AsyncValue.error(l.message.toString(), StackTrace.current),
      (r) => state = AsyncValue.data(r),
    );
  }

  // This method is called when the notifier is first created. It's a good place to initialize any dependencies.
  @override
  void build() {
    authRepository = ref.read(authRepositoryProvider);
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifer, void>(AuthStateNotifer.new);
