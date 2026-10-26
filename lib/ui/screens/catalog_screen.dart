import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';
import '../widgets/book_card.dart';

/// Список элементов каталога: константа, вне метода build.
const books = <Book>[
  Book(
    id: 1,
    title: 'Мастер и Маргарита',
    subtitle: 'Михаил Булгаков',
    category: Category.classic,
    color: 0xFF5C6BC0,
    year: 1967,
    description:
        'Роман о визите Воланда в Москву 1930-х годов: история Мастера, его романа о Понтии Пилате и любви, которая сильнее времени.',
  ),
  Book(
    id: 2,
    title: 'Собака Баскервилей',
    subtitle: 'Артур Конан Дойл',
    category: Category.detective,
    color: 0xFF26A69A,
    year: 1902,
    description:
        'Шерлок Холмс и доктор Ватсон расследуют загадочную смерть сэра Чарльза Баскервиля и семейное проклятие в Дартмуре.',
  ),
  Book(
    id: 3,
    title: 'Властелин колец',
    subtitle: 'Дж. Р. Р. Толкин',
    category: Category.fantasy,
    color: 0xFF7E57C2,
    year: 1954,
    description:
        'Хоббит Фродо отправляется в Мордор, чтобы уничтожить Кольцо Всевластия и спасти Средиземье от Саурона.',
  ),
  Book(
    id: 4,
    title: 'Дюна',
    subtitle: 'Фрэнк Герберт',
    category: Category.scifi,
    color: 0xFFEF6C00,
    year: 1965,
    description:
        'На пустынной планете Арракис юный Пол Атрейдес возглавляет борьбу за самую ценную субстанцию Вселенной — пряность.',
  ),
  Book(
    id: 5,
    title: 'Гарри Поттер и философский камень',
    subtitle: 'Дж. К. Роулинг',
    category: Category.fantasy,
    color: 0xFF8D6E63,
    year: 1997,
    description:
        'Мальчик-волшебник поступает в школу Хогвартс, находит верных друзей и узнаёт правду о гибели родителей.',
  ),
  Book(
    id: 6,
    title: 'Пикник на обочине',
    subtitle: 'Аркадий и Борис Стругацкие',
    category: Category.scifi,
    color: 0xFF546E7A,
    year: 1972,
    description:
        'Сталкер Рэдрик Шухарт ходит в Зону за артефактами, оставленными пришельцами, и платит за это высокую цену.',
  ),
  Book(
    id: 7,
    title: 'Маленький принц',
    subtitle: 'Антуан де Сент-Экзюпери',
    category: Category.classic,
    color: 0xFF42A5F5,
    year: 1943,
    description:
        'Пилот, потерпевший крушение в Сахаре, знакомится с маленьким принцем с далёкой планеты и учится видеть главное.',
  ),
  Book(
    id: 8,
    title: 'Три товарища',
    subtitle: 'Эрих Мария Ремарк',
    category: Category.classic,
    color: 0xFFAB47BC,
    year: 1936,
    description:
        'История дружбы трёх фронтовых товарищей и любви Роберта Локампа к Пат в Германии между двумя войнами.',
  ),
  Book(
    id: 9,
    title: 'Хоббит, или Туда и обратно',
    subtitle: 'Дж. Р. Р. Толкин',
    category: Category.fantasy,
    color: 0xFF66BB6A,
    year: 1937,
    description:
        'Бильбо Бэггинс отправляется с гномами к Одинокой горе, чтобы отвоевать сокровища у дракона Смауга.',
  ),
  Book(
    id: 10,
    title: '451 градус по Фаренгейту',
    subtitle: 'Рэй Брэдбери',
    category: Category.scifi,
    color: 0xFFFF7043,
    year: 1953,
    description:
        'В будущем, где книги запрещены и сжигаются, пожарный Гай Монтэг начинает сомневаться в системе и читать.',
  ),
  Book(
    id: 11,
    title: 'Убийство в «Восточном экспрессе»',
    subtitle: 'Агата Кристи',
    category: Category.detective,
    color: 0xFFEC407A,
    year: 1934,
    description:
        'Эркюль Пуаро расследует убийство пассажира в поезде, застрявшем в снегах, где подозреваемым оказывается каждый.',
  ),
  Book(
    id: 12,
    title: 'Двенадцать стульев',
    subtitle: 'Илья Ильф и Евгений Петров',
    category: Category.adventure,
    color: 0xFFFFA726,
    year: 1928,
    description:
        'Великий комбинатор Остап Бендер и Киса Воробьянинов ищут бриллианты, спрятанные в одном из двенадцати стульев.',
  ),
];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  /// Лайки хранятся как набор id.
  final Set<int> _likedIds = <int>{};

  bool _favoritesOnly = false;

  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Отфильтрованный список считаем прямо в build через where.
    final filtered = _favoritesOnly
        ? books.where((book) => _likedIds.contains(book.id)).toList()
        : books;

    return Scaffold(
      appBar: AppBar(title: const Text('Каталог книг')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  'В избранном: ${_likedIds.length}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                FilterChip(
                  label: const Text('Только избранные'),
                  selected: _favoritesOnly,
                  onSelected: (value) =>
                      setState(() => _favoritesOnly = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Ничего не нашлось'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final book = filtered[index];
                      return BookCard(
                        book: book,
                        isLiked: _likedIds.contains(book.id),
                        onLikeTap: () => _toggleLike(book.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
