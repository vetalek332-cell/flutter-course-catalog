import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';
import 'category_icon.dart';
import 'like_button.dart';

/// Безопасно превращает hex-строку вида '5C6BC0' в цвет обложки.
Color bookCoverColor(String hex) {
  final value = int.tryParse('FF${hex.replaceAll('#', '')}', radix: 16);
  return value == null ? const Color(0xFF5C6BC0) : Color(value);
}

/// Карточка книги: обложка с Hero-анимацией, название, подпись,
/// иконка категории и кнопка лайка.
/// Stateless: данные приходят параметрами, событие лайка — колбэком.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.isLiked,
    required this.onLikeTap,
    this.onOpen,
  });

  final Book book;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final color = bookCoverColor(book.color);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    // Дополнительная опция «Анимации»: Hero обложки
                    // при переходе в детали.
                    Hero(
                      tag: 'book-cover-${book.id}',
                      child: Container(
                        width: 92,
                        height: 122,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.lerp(color, Colors.black, 0.25)!,
                              color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          book.title.isEmpty ? '?' : book.title.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Анимированная кнопка лайка поверх обложки.
                    Positioned(
                      top: 6,
                      right: 6,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: LikeButton(
                          isLiked: isLiked,
                          onTap: onLikeTap,
                          size: 18,
                          deactiveColor: const Color(0xFF8A8A8A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
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
                                const SizedBox(width: 4),
                                Text(
                                  book.category.label,
                                  style: theme.textTheme.labelMedium
                                      ?.copyWith(color: color),
                                ),
                              ],
                            ),
                          ),
                          if (book.year != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${book.year}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
