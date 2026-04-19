import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:riverpod_practice/injection.dart';
import 'package:riverpod_practice/repository/auth_respository.dart';

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
  Future<void> build() async {
    authRepository = getIt<AuthRepository>();
  }
}

final authStateProvider =   AsyncNotifierProvider<AuthStateNotifer, void>(AuthStateNotifer.new);
