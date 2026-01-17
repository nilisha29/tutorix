import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/auth/domain/usecases/login_usecase.dart';
import 'package:tutorix/features/auth/domain/usecases/register_usecase.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return AuthState(); 
  }

  /// REGISTER
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    final result = await _registerUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

 Future<void> login({
  required String username,
  required String password,
}) async {
  print('[DEBUG] login() called with $username'); // ✅ start
  state = state.copyWith(status: AuthStatus.loading);

  final params = LoginUsecaseParams(email: username, password: password);
  final result = await _loginUsecase.call(params);

  print('[DEBUG] login() result: $result'); // ✅ after API call

  result.fold(
    (failure) {
      print('[DEBUG] login() failure: ${failure.message}'); // ✅ failure
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    },
    
    (authEntity) {
      print('[DEBUG] login() success: ${authEntity.email}'); // ✅ success
      state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      );
    },
  );
}
}








