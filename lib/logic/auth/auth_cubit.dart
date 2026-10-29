import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final bool submitting;
  final String? error;
  final String? info;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.submitting = false,
    this.error,
    this.info,
  });

  const AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        submitting = false,
        error = null,
        info = null;

  const AuthState.unauthenticated({
    this.submitting = false,
    this.error,
    this.info,
  })  : status = AuthStatus.unauthenticated,
        user = null;
}

/// Управляет состоянием авторизации: вход, регистрация, выход,
/// восстановление пароля и подписка на authStateChanges.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;
  StreamSubscription<User?>? _subscription;

  /// Подписка на поток входа/выхода: при запуске приложения
  /// срабатывает сразу, поэтому залогиненный пользователь остаётся в системе.
  void start() {
    _subscription = _authRepository.authStateChanges().listen((user) {
      if (isClosed) return;
      emit(
        user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      );
    });
  }

  Future<void> signInRequested(String email, String password) async {
    emit(const AuthState.unauthenticated(submitting: true));
    try {
      await _authRepository.signIn(email: email, password: password);
      // При успехе сработает authStateChanges и переведёт в authenticated.
    } on FirebaseAuthException catch (error) {
      emit(AuthState.unauthenticated(error: authErrorMessage(error.code)));
    } catch (error) {
      emit(AuthState.unauthenticated(error: 'Не удалось войти: $error'));
    }
  }

  Future<void> registerRequested(String email, String password) async {
    emit(const AuthState.unauthenticated(submitting: true));
    try {
      await _authRepository.register(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      emit(AuthState.unauthenticated(error: authErrorMessage(error.code)));
    } catch (error) {
      emit(AuthState.unauthenticated(error: 'Не удалось зарегистрироваться: $error'));
    }
  }

  /// Сброс пароля письмом на почту (экран профиля).
  Future<void> passwordResetRequested(String email) async {
    emit(const AuthState.unauthenticated(submitting: true));
    try {
      await _authRepository.sendPasswordReset(email: email);
      emit(const AuthState.unauthenticated(
        info: 'Письмо для сброса пароля отправлено на почту',
      ));
    } on FirebaseAuthException catch (error) {
      emit(AuthState.unauthenticated(error: authErrorMessage(error.code)));
    } catch (error) {
      emit(AuthState.unauthenticated(error: 'Не удалось отправить письмо: $error'));
    }
  }

  Future<void> logoutRequested() async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
