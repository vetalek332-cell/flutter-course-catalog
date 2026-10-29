import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_cubit.dart';
import '../../logic/catalog/catalog_bloc.dart';
import '../../logic/theme/theme_cubit.dart';

/// Дополнительная опция «Профиль»: email, количество избранного,
/// тёмная тема, сброс пароля письмом и выход.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final catalogState = context.watch<CatalogBloc>().state;
    final email = authState.user?.email ?? '—';
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.info != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.info!)),
          );
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Профиль')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  email.isEmpty ? '?' : email.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                email,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.favorite_outline),
                    title: const Text('В избранном'),
                    trailing: Text(
                      '${catalogState.favoritesCount}',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.library_books_outlined),
                    title: const Text('Книг в каталоге'),
                    trailing: Text(
                      '${catalogState.books.length}',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) {
                  return SwitchListTile(
                    secondary: Icon(mode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode),
                    title: const Text('Тёмная тема'),
                    subtitle: const Text('Выбор сохраняется после перезапуска'),
                    value: mode == ThemeMode.dark,
                    onChanged: (_) =>
                        context.read<ThemeCubit>().toggle(),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset),
                    title: const Text('Сбросить пароль'),
                    subtitle: Text('Придёт письмо на $email'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context
                        .read<AuthCubit>()
                        .passwordResetRequested(email),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Выйти',
                    style: TextStyle(color: Colors.red)),
                onTap: () => context.read<AuthCubit>().logoutRequested(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
