import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/book.dart';
import '../../logic/catalog/catalog_bloc.dart';

/// Экран добавления (book == null) и редактирования элемента.
/// Обязательное поле одно — «Название», пустое название не отправляется.
class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});

  final Book? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController =
      TextEditingController(text: widget.book?.title);
  late final TextEditingController _subtitleController =
      TextEditingController(text: widget.book?.subtitle);
  late final TextEditingController _yearController =
      TextEditingController(text: widget.book?.year?.toString() ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.book?.description ?? '');

  late Category _category = widget.book?.category ?? Category.classic;

  /// Цвет обложки по умолчанию — по выбранной категории.
  String get _defaultColor => switch (_category) {
        Category.classic => '5C6BC0',
        Category.fantasy => '7E57C2',
        Category.scifi => 'EF6C00',
        Category.detective => '26A69A',
        Category.adventure => 'FFA726',
      };

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final year = int.tryParse(_yearController.text.trim());
    final description = _descriptionController.text.trim();

    final base = widget.book ??
        const Book(id: '', title: '', subtitle: '', category: Category.classic);

    final book = base.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      category: _category,
      year: year,
      description: description.isEmpty ? null : description,
      color: widget.book?.color ?? _defaultColor,
    );

    final bloc = context.read<CatalogBloc>();
    if (widget.book == null) {
      bloc.add(CatalogBookAdded(book));
    } else {
      bloc.add(CatalogBookUpdated(book));
    }
    // Список обновится сам через поток Firestore — возвращаемся назад.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование' : 'Новая книга'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Введите название' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Подпись (автор)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final category in Category.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _category = value ?? Category.classic),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Год издания',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return null;
                return int.tryParse(text) == null
                    ? 'Введите число, например 1967'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: Text(isEditing ? 'Сохранить изменения' : 'Добавить книгу'),
            ),
          ],
        ),
      ),
    );
  }
}
