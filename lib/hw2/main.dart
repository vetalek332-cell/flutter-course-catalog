import 'package:flutter/material.dart';

/// Домашнее задание 2 — «Экран списка каталога».
/// Тема: книги. Весь код этого задания — в одном файле.

void main() => runApp(const CatalogApp());

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Каталог книг',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C6BC0)),
      ),
      home: const CatalogScreen(),
    );
  }
}

/// Модель данных одного элемента каталога (для ДЗ 2).
class _Book {
  final int id;
  final String title;
  final String subtitle;
  final String category; // classic | fantasy | scifi | detective | adventure
  final int color; // цвет обложки, например 0xFF5C6BC0
  final int? year;

  const _Book(
    this.id,
    this.title,
    this.subtitle,
    this.category,
    this.color, [
    this.year,
  ]);
}

/// Список из 12 элементов каталога.
const books = <_Book>[
  _Book(1, 'Мастер и Маргарита', 'Михаил Булгаков', 'classic', 0xFF5C6BC0, 1967),
  _Book(2, 'Собака Баскервилей', 'Артур Конан Дойл', 'detective', 0xFF26A69A, 1902),
  _Book(3, 'Властелин колец', 'Дж. Р. Р. Толкин', 'fantasy', 0xFF7E57C2, 1954),
  _Book(4, 'Дюна', 'Фрэнк Герберт', 'scifi', 0xFFEF6C00, 1965),
  _Book(5, 'Гарри Поттер и философский камень', 'Дж. К. Роулинг', 'fantasy', 0xFF8D6E63, 1997),
  _Book(6, 'Пикник на обочине', 'Аркадий и Борис Стругацкие', 'scifi', 0xFF546E7A, 1972),
  _Book(7, 'Маленький принц', 'Антуан де Сент-Экзюпери', 'classic', 0xFF42A5F5, 1943),
  _Book(8, 'Три товарища', 'Эрих Мария Ремарк', 'classic', 0xFFAB47BC, 1936),
  _Book(9, 'Хоббит, или Туда и обратно', 'Дж. Р. Р. Толкин', 'fantasy', 0xFF66BB6A, 1937),
  _Book(10, '451 градус по Фаренгейту', 'Рэй Брэдбери', 'scifi', 0xFFFF7043, 1953),
  _Book(11, 'Убийство в «Восточном экспрессе»', 'Агата Кристи', 'detective', 0xFFEC407A, 1934),
  _Book(12, 'Двенадцать стульев', 'Илья Ильф и Евгений Петров', 'adventure', 0xFFFFA726, 1928),
];

IconData _categoryIcon(String category) => switch (category) {
      'fantasy' => Icons.auto_stories,
      'scifi' => Icons.rocket_launch,
      'detective' => Icons.search,
      'adventure' => Icons.explore,
      _ => Icons.menu_book,
    };

String _categoryLabel(String category) => switch (category) {
      'classic' => 'Классика',
      'fantasy' => 'Фэнтези',
      'scifi' => 'Фантастика',
      'detective' => 'Детектив',
      'adventure' => 'Приключения',
      _ => 'Книга',
    };

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Каталог книг')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: books.length,
        itemBuilder: (context, index) => _BookCard(book: books[index]),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final _Book book;

  @override
  Widget build(BuildContext context) {
    final color = Color(book.color);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Обложка — Stack из трёх слоёв.
            Stack(
              children: [
                // Слой 1: цветной контейнер с градиентом.
                Container(
                  width: 96,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.lerp(color, Colors.black, 0.25)!, color],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  // Слой 2: первая буква названия по центру.
                  child: Text(
                    book.title.isEmpty ? '?' : book.title.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Слой 3: значок лайка в правом верхнем углу.
                const Positioned(
                  top: 6,
                  right: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFFE53935),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Блок с текстом занимает всё место справа от обложки.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(_categoryIcon(book.category), size: 16, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _categoryLabel(book.category),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                      if (book.year != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${book.year}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
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
    );
  }
}
