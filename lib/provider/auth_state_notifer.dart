import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:riverpod_practice/api_service/auth_api_service.dart';
import 'package:riverpod_practice/api_service/i_auth_api_service.dart';
import 'package:riverpod_practice/local_service/auth_local_service.dart';
import 'package:riverpod_practice/provider/auth_state.dart';
import 'package:riverpod_practice/repository/auth_respository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.read(authApiServiceProvider);
  final localService = ref.read(authLocalServiceProvider);
  return IAuthRepository(apiService, localService);
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return IAuthApiService();
});

final authLocalServiceProvider = Provider<AuthLocalService>((ref) {
  return AuthLocalServiceImpl();
});

@injectable
class AuthStateNotifer extends AsyncNotifier<AuthState> {
  late AuthRepository authRepository;
  AuthStateNotifer() : super();

  void login({required String userName, required String password}) async {
    // Implement login logic here
    state = AsyncLoading();
    // Simulate a login process
    final result =
        await authRepository.login(userName: userName, password: password);
    result.fold(
        (l) => state =
            AsyncValue.error(state.value!.copyWith(isSuccess: false, errorMessage: l.message), StackTrace.current), (r) {

      // Save credentials locally after successful login \\        
      authRepository.saveCredentials(email: userName, password: password);
      state = AsyncValue.data(state.value!.copyWith(isSuccess: true));
    });
  }

  // change slider value
  void changeSliderValue(double value){
    if(state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(sliderValue: value));
  }

  // change selected gender
  void changeSelectedGender(String gender) {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(selectedGender: gender));
  }

  // toggle password visibility
  void togglePasswordVisibility() {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(isPasswordVisible: !state.value!.isPasswordVisible));
  }

  // This method is called when the notifier is first created. It's a good place to initialize any dependencies.
  @override
  FutureOr<AuthState> build() {
    authRepository = ref.read(authRepositoryProvider);
    return AuthState();
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifer, AuthState>(AuthStateNotifer.new);
