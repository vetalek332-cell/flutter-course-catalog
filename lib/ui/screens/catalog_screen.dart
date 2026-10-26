import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';
import '../widgets/book_card.dart';

/// Экран каталога: данные читаются из коллекции Firestore через snapshots().
/// Добавление создаёт документ в Firestore, лайки и фильтр — локально.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  /// Поток — поле State, не внутри build.
  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream;

  bool _showForm = false;
  bool _sending = false;

  final Set<String> _likedIds = <String>{};
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _itemsStream = FirebaseFirestore.instance.collection('books').snapshots();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  /// Кнопка «Обновить»: заново подписываемся на поток.
  void _retry() {
    setState(() {
      _itemsStream =
          FirebaseFirestore.instance.collection('books').snapshots();
    });
  }

  void _toggleLike(String id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      // Пустое название не отправляется.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final book = Book(
        id: '',
        title: title,
        subtitle: _subtitleController.text.trim().isEmpty
            ? 'Без подписи'
            : _subtitleController.text.trim(),
        category: Category.classic,
        description: '',
      );
      // Добавление создаёт документ в Firestore, список обновится сам.
      await FirebaseFirestore.instance
          .collection('books')
          .add(book.toJson());
      if (!mounted) return;
      _titleController.clear();
      _subtitleController.clear();
      setState(() => _showForm = false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить: $error')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Заполняет пустую коллекцию 12 книгами одним батчем.
  Future<void> _seedDemoData() async {
    final store = FirebaseFirestore.instance;
    final batch = store.batch();
    for (var i = 0; i < demoBooks.length; i++) {
      final ref = store.collection('books').doc();
      batch.set(ref, demoBooks[i].toJson());
    }
    await batch.commit();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог книг'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm) _buildForm(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  'В избранном: ${_likedIds.length}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _itemsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _ErrorView(
                    message:
                        'Не удалось загрузить каталог: ${snapshot.error}',
                    onRetry: _retry,
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = snapshot.data?.docs
                        .map(Book.fromFirestore)
                        .toList() ??
                    const <Book>[];

                // Совсем пустая коллекция — предложим заполнить демо-данными.
                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('В каталоге пока пусто'),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: _seedDemoData,
                          icon: const Icon(Icons.auto_stories),
                          label: const Text('Заполнить демо-данными'),
                        ),
                      ],
                    ),
                  );
                }

                final filtered = _favoritesOnly
                    ? books
                        .where((book) => _likedIds.contains(book.id))
                        .toList()
                    : books;

                if (filtered.isEmpty) {
                  return const Center(child: Text('Ничего не нашлось'));
                }

                return ListView.builder(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Название *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Подпись (автор, необязательно)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Отправить'),
              ),
            ],
          ),
        ],
      ),
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
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
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

/// Демо-данные каталога: 12 книг. Заполняются кнопкой на пустом экране
/// (по заданию достаточно добавить 8+ элементов формой — это просто быстрее).
const demoBooks = <Book>[
  Book(
    id: '',
    title: 'Мастер и Маргарита',
    subtitle: 'Михаил Булгаков',
    category: Category.classic,
    color: '5C6BC0',
    year: 1967,
    tags: ['роман', 'мистика'],
    description:
        'Роман о визите Воланда в Москву 1930-х годов: история Мастера, его романа о Понтии Пилате и любви, которая сильнее времени.',
  ),
  Book(
    id: '',
    title: 'Собака Баскервилей',
    subtitle: 'Артур Конан Дойл',
    category: Category.detective,
    color: '26A69A',
    year: 1902,
    tags: ['шерлок холмс', 'классика детектива'],
    description:
        'Шерлок Холмс и доктор Ватсон расследуют загадочную смерть сэра Чарльза Баскервиля и семейное проклятие в Дартмуре.',
  ),
  Book(
    id: '',
    title: 'Властелин колец',
    subtitle: 'Дж. Р. Р. Толкин',
    category: Category.fantasy,
    color: '7E57C2',
    year: 1954,
    tags: ['эпическое фэнтези', 'трилогия'],
    description:
        'Хоббит Фродо отправляется в Мордор, чтобы уничтожить Кольцо Всевластия и спасти Средиземье от Саурона.',
  ),
  Book(
    id: '',
    title: 'Дюна',
    subtitle: 'Фрэнк Герберт',
    category: Category.scifi,
    color: 'EF6C00',
    year: 1965,
    tags: ['фантастика', 'эпопея'],
    description:
        'На пустынной планете Арракис юный Пол Атрейдес возглавляет борьбу за самую ценную субстанцию Вселенной — пряность.',
  ),
  Book(
    id: '',
    title: 'Гарри Поттер и философский камень',
    subtitle: 'Дж. К. Роулинг',
    category: Category.fantasy,
    color: '8D6E63',
    year: 1997,
    tags: ['детская фантастика', 'школа'],
    description:
        'Мальчик-волшебник поступает в школу Хогвартс, находит верных друзей и узнаёт правду о гибели родителей.',
  ),
  Book(
    id: '',
    title: 'Пикник на обочине',
    subtitle: 'Аркадий и Борис Стругацкие',
    category: Category.scifi,
    color: '546E7A',
    year: 1972,
    tags: ['советская фантастика', 'сталкер'],
    description:
        'Сталкер Рэдрик Шухарт ходит в Зону за артефактами, оставленными пришельцами, и платит за это высокую цену.',
  ),
  Book(
    id: '',
    title: 'Маленький принц',
    subtitle: 'Антуан де Сент-Экзюпери',
    category: Category.classic,
    color: '42A5F5',
    year: 1943,
    tags: ['философская сказка'],
    description:
        'Пилот, потерпевший крушение в Сахаре, знакомится с маленьким принцем с далёкой планеты и учится видеть главное.',
  ),
  Book(
    id: '',
    title: 'Три товарища',
    subtitle: 'Эрих Мария Ремарк',
    category: Category.classic,
    color: 'AB47BC',
    year: 1936,
    tags: ['роман о дружбе', 'XX век'],
    description:
        'История дружбы трёх фронтовых товарищей и любви Роберта Локампа к Пат в Германии между двумя войнами.',
  ),
  Book(
    id: '',
    title: 'Хоббит, или Туда и обратно',
    subtitle: 'Дж. Р. Р. Толкин',
    category: Category.fantasy,
    color: '66BB6A',
    year: 1937,
    tags: ['приключения', 'Средиземье'],
    description:
        'Бильбо Бэггинс отправляется с гномами к Одинокой горе, чтобы отвоевать сокровища у дракона Смауга.',
  ),
  Book(
    id: '',
    title: '451 градус по Фаренгейту',
    subtitle: 'Рэй Брэдбери',
    category: Category.scifi,
    color: 'FF7043',
    year: 1953,
    tags: ['антиутопия', 'запрещённые книги'],
    description:
        'В будущем, где книги запрещены и сжигаются, пожарный Гай Монтэг начинает сомневаться в системе и читать.',
  ),
  Book(
    id: '',
    title: 'Убийство в «Восточном экспрессе»',
    subtitle: 'Агата Кристи',
    category: Category.detective,
    color: 'EC407A',
    year: 1934,
    tags: ['пуаро', 'детектив'],
    description:
        'Эркюль Пуаро расследует убийство пассажира в поезде, застрявшем в снегах, где подозреваемым оказывается каждый.',
  ),
  Book(
    id: '',
    title: 'Двенадцать стульев',
    subtitle: 'Илья Ильф и Евгений Петров',
    category: Category.adventure,
    color: 'FFA726',
    year: 1928,
    tags: ['сатира', 'авантюра'],
    description:
        'Великий комбинатор Остап Бендер и Киса Воробьянинов ищут бриллианты, спрятанные в одном из двенадцати стульев.',
  ),
];
