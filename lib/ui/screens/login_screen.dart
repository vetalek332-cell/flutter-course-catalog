import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_cubit.dart';

/// Экран входа и регистрации по email и паролю.
/// Ошибки показываются понятным текстом прямо на экране.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    context.read<AuthCubit>().signInRequested(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  void _register() {
    context.read<AuthCubit>().registerRequested(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  void _resetPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите email в поле выше')),
      );
      return;
    }
    context.read<AuthCubit>().passwordResetRequested(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Книжный каталог',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Войдите, чтобы продолжить',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: theme.colorScheme.onErrorContainer),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.error!,
                                  style: TextStyle(
                                      color: theme.colorScheme.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: state.submitting ? null : _signIn,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: state.submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Войти'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: state.submitting ? null : _register,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Зарегистрироваться'),
                      ),
                      TextButton(
                        onPressed: state.submitting ? null : _resetPassword,
                        child: const Text('Забыли пароль?'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
