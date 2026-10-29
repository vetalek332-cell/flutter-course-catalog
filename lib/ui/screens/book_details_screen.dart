import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../logic/catalog/catalog_bloc.dart';
import '../widgets/book_card.dart' show bookCoverColor;
import '../widgets/category_icon.dart';
import '../widgets/like_button.dart';
import 'book_form_screen.dart';

/// Экран деталей: полная информация об элементе.
/// Лайк совпадает со списком — данные берутся из CatalogBloc.
/// Дополнительная опция «Редактирование и удаление».
class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        final book = state.books
            .where((book) => book.id == bookId)
            .firstOrNull;

        // Элемент мог быть удалён из Firebase Console — не падаем.
        if (book == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bookmark_border, size: 64),
                  const SizedBox(height: 16),
                  const Text('Элемент больше не существует'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Назад'),
                  ),
                ],
              ),
            ),
          );
        }

        final isLiked = state.likedIds.contains(book.id);
        final color = bookCoverColor(book.color);
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                tooltip: 'Редактировать',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BookFormScreen(book: book),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Удалить',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, book),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Дополнительная опция «Анимации»: Hero обложки.
                  Hero(
                    tag: 'book-cover-${book.id}',
                    child: Container(
                      width: 120,
                      height: 170,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.lerp(color, Colors.black, 0.25)!,
                            color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        book.title.isEmpty ? '?' : book.title.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                categoryIcon(book.category),
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                book.category.label,
                                style: theme.textTheme.labelMedium
                                    ?.copyWith(color: color),
                              ),
                            ],
                          ),
                        ),
                        if (book.year != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 14),
                              const SizedBox(width: 6),
                              Text('${book.year} год издания'),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => context
                              .read<CatalogBloc>()
                              .add(CatalogLikeToggled(book.id)),
                          icon: LikeButton(isLiked: isLiked, size: 18),
                          label: Text(isLiked
                              ? 'В избранном'
                              : 'Добавить в избранное'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if ((book.description ?? '').isNotEmpty) ...[
                Text('Описание', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  book.description!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
              ],
              if (book.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in book.tags)
                      Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  /// Удаление — только после диалога подтверждения.
  Future<void> _confirmDelete(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить книгу?'),
        content: Text(
          '«${book.title}» исчезнет из каталога для всех пользователей.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      if (!context.mounted) return;
      context.read<CatalogBloc>().add(CatalogBookDeleted(book.id));
      Navigator.of(context).pop();
    }
  }
}
