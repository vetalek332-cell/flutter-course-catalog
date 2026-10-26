import 'package:flutter/material.dart';

import '../../data/books_api.dart';
import '../../domain/entities/book.dart';
import '../widgets/book_card.dart';

/// Экран каталога: список загружается GET-запросом с сервера MockAPI,
/// новые элементы отправляются POST-запросом и сохраняются на сервере.
/// Лайки и фильтр «Только избранные» — локально.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final BooksApi _api = BooksApi();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  List<Book> _books = <Book>[];
  _LoadStatus _status = _LoadStatus.loading;
  String? _error;

  bool _showForm = false;
  bool _sending = false;

  final Set<String> _likedIds = <String>{};
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() => _status = _LoadStatus.loading);
    try {
      final books = await _api.fetchBooks();
      if (!mounted) return;
      setState(() {
        _books = books;
        _status = _LoadStatus.data;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _status = _LoadStatus.error;
      });
    }
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
      final created = await _api.createBook(
        Book(
          id: '',
          title: title,
          subtitle: _subtitleController.text.trim().isEmpty
              ? 'Без подписи'
              : _subtitleController.text.trim(),
          category: Category.classic,
          description: '',
        ),
      );
      if (!mounted) return;
      setState(() {
        // Новый элемент — в начало списка.
        _books = [created, ..._books];
        _titleController.clear();
        _subtitleController.clear();
        _showForm = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отправить: $error')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _favoritesOnly
        ? _books.where((book) => _likedIds.contains(book.id)).toList()
        : _books;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог книг'),
        actions: [
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
            child: switch (_status) {
              _LoadStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
              _LoadStatus.error => _ErrorView(
                  message: _error ?? 'Не удалось загрузить каталог',
                  onRetry: _loadBooks,
                ),
              _LoadStatus.data => filtered.isEmpty
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
            },
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

enum _LoadStatus { loading, data, error }

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
