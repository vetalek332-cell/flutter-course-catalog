import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/catalog/catalog_bloc.dart';
import 'catalog_screen.dart';
import 'login_screen.dart';

/// Показывает экран входа, пока пользователь не авторизован.
/// После входа создаётся CatalogBloc (BlocProvider) и вложенный
/// навигатор экранов каталога.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return BlocProvider<CatalogBloc>(
              create: (_) => CatalogBloc(
                repository: CatalogRepository(),
                uid: state.user!.uid,
              )..add(const CatalogStarted()),
              child: Navigator(
                onGenerateRoute: (settings) => MaterialPageRoute<void>(
                  builder: (_) => const CatalogScreen(),
                  settings: settings,
                ),
              ),
            );
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.unknown:
            // Пока восстанавливается сессия после перезапуска — индикатор.
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
