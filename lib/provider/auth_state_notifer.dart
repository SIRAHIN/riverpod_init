import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/injection.dart';
import 'package:riverpod_practice/provider/auth_state.dart';
import 'package:riverpod_practice/repository/auth_respository.dart';

class AuthStateNotifer extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  AuthStateNotifer(this.authRepository) : super(AuthInitial());

  void login({required String userName, required String password}) async {
    // Implement login logic here
    state = AuthLoading();
    // Simulate a login process
    final result =
        await authRepository.login(userName: userName, password: password);
    result.fold(
      (l) => state = AuthFailure(l.message.toString()),
      (r) => state = AuthSuccess(),
    );
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifer, AuthState>(
  (ref) => AuthStateNotifer(getIt<AuthRepository>()),
);
