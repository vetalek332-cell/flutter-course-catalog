import 'package:firebase_auth/firebase_auth.dart';

/// Все обращения к Firebase Authentication — только здесь.
/// Виджеты и Cubit работают с этим классом, Firebase напрямую не трогают.
class AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Поток состояния входа: срабатывает и при запуске (восстановление сессии).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register({required String email, required String password}) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordReset({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();
}

/// Человекочитаемые сообщения по кодам ошибок Firebase Auth.
String authErrorMessage(String code) => switch (code) {
      'invalid-email' => 'Неверный формат email',
      'invalid-credential' => 'Неверный email или пароль',
      'user-not-found' => 'Пользователь с таким email не найден',
      'wrong-password' => 'Неверный пароль',
      'email-already-in-use' => 'Этот email уже занят, попробуйте войти',
      'weak-password' => 'Слишком короткий пароль (минимум 6 символов)',
      'network-request-failed' => 'Нет соединения с интернетом',
      'too-many-requests' => 'Слишком много попыток, попробуйте позже',
      'user-disabled' => 'Этот аккаунт отключён',
      _ => 'Ошибка: $code',
    };
