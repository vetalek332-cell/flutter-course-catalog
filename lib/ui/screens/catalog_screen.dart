import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../logic/catalog/catalog_bloc.dart';
import '../../logic/theme/theme_cubit.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_view.dart';
import 'book_details_screen.dart';
import 'book_form_screen.dart';
import 'profile_screen.dart';

/// Экран каталога: поиск, фильтры, сортировка, три состояния
/// (загрузка / ошибка / данные). Данными управляет CatalogBloc.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Книжный каталог'),
            actions: [
              // Дополнительная опция «Тёмная тема».
              IconButton(
                icon: Icon(
                  context.watch<ThemeCubit>().state == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () => context.read<ThemeCubit>().toggle(),
              ),
              IconButton(
                tooltip: 'Профиль',
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileScreen(),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BookFormScreen(),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Добавить'),
          ),
          body: Column(
            children: [
              // Дополнительная опция «Поиск»: фильтрация во время ввода.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => context
                      .read<CatalogBloc>()
                      .add(CatalogQueryChanged(value)),
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<CatalogBloc>().add(
                                    const CatalogQueryChanged(''),
                                  );
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              // Дополнительная опция «Фильтры и сортировка».
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          FilterChip(
                            label: Text('Избранное · ${state.favoritesCount}'),
                            selected: state.favoritesOnly,
                            onSelected: (_) => context
                                .read<CatalogBloc>()
                                .add(const CatalogFavoritesOnlyToggled()),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Все'),
                            selected: state.categoryFilter == null,
                            onSelected: (_) => context
                                .read<CatalogBloc>()
                                .add(const CatalogCategorySelected(null)),
                          ),
                          for (final category in Category.values)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(category.label),
                                selected:
                                    state.categoryFilter == category,
                                onSelected: (_) =>
                                    context.read<CatalogBloc>().add(
                                          CatalogCategorySelected(category),
                                        ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<CatalogSort>(
                      icon: const Icon(Icons.sort),
                      tooltip: 'Сортировка',
                      initialValue: state.sort,
                      onSelected: (sort) => context
                          .read<CatalogBloc>()
                          .add(CatalogSortSelected(sort)),
                      itemBuilder: (_) => [
                        for (final sort in CatalogSort.values)
                          PopupMenuItem(
                            value: sort,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: sort == state.sort
                                      ? const Icon(Icons.check, size: 18)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(sort.label),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: switch (state.status) {
                  CatalogStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  CatalogStatus.error => _ErrorView(
                      message: state.error ?? 'Не удалось загрузить каталог',
                      onRetry: () => context.read<CatalogBloc>().add(
                            const CatalogRefreshRequested(),
                          ),
                    ),
                  CatalogStatus.loaded => _buildList(context, state),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, CatalogState state) {
    final books = state.visibleBooks;

    if (books.isEmpty) {
      // Пустой список — заглушка с текстом.
      if (state.favoritesOnly &&
          state.categoryFilter == null &&
          state.query.trim().isEmpty) {
        return const EmptyView(
          icon: Icons.favorite_border,
          title: 'В избранном пока пусто',
          subtitle: 'Нажмите на сердечко в карточке, чтобы добавить книгу',
        );
      }
      if (state.hasActiveFilters) {
        return const EmptyView(
          icon: Icons.search_off,
          title: 'Ничего не нашлось',
          subtitle: 'Попробуйте изменить фильтры или очистить поиск',
        );
      }
      return EmptyView(
        icon: Icons.library_books,
        title: 'В каталоге пока пусто',
        subtitle: 'Добавьте первую книгу или заполните демо-данными',
        action: FilledButton.tonalIcon(
          onPressed: () => context
              .read<CatalogBloc>()
              .add(const CatalogDemoDataRequested()),
          icon: const Icon(Icons.auto_stories),
          label: const Text('Заполнить демо-данными'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          isLiked: state.likedIds.contains(book.id),
          onLikeTap: () => context
              .read<CatalogBloc>()
              .add(CatalogLikeToggled(book.id)),
          onOpen: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BookDetailsScreen(bookId: book.id),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 56),
            const SizedBox(height: 12),
            Text(
              'Не удалось загрузить каталог',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }
}
