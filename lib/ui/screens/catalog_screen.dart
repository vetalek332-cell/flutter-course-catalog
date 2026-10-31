import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../logic/books/books_bloc.dart';
import '../../logic/books/books_event.dart';
import '../../logic/books/books_state.dart';
import '../widgets/book_card.dart';

/// Экран каталога: данными управляет BooksBloc, виджеты строятся
/// через BlocBuilder. Лайки и фильтр «Только избранные» — локально
/// на setState (по заданию, переедут в Bloc позже).
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  bool _showForm = false;
  bool _sending = false;

  final Set<String> _likedIds = <String>{};
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
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
      // Добавление идёт через Bloc, список обновится сам.
      await context.read<BooksBloc>().addBook(book);
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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BooksBloc()..add(const BooksLoadRequested()),
      child: Scaffold(
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
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
              child: BlocBuilder<BooksBloc, BooksState>(
                builder: (context, state) {
                  if (state is BooksLoadInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is BooksLoadFailure) {
                    return _ErrorView(
                      message: state.message,
                      // Заново запускает загрузку.
                      onRetry: () => context
                          .read<BooksBloc>()
                          .add(const BooksLoadRequested()),
                    );
                  }

                  final books = (state as BooksLoadSuccess).books;

                  // Совсем пустая коллекция — предложим заполнить демо-данными.
                  if (books.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('В каталоге пока пусто'),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                context.read<BooksBloc>().seedDemoData(),
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
