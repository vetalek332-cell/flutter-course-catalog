import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель одного элемента каталога — книги.

enum Category { classic, fantasy, scifi, detective, adventure }

extension CategoryLabel on Category {
  String get label => switch (this) {
        Category.classic => 'Классика',
        Category.fantasy => 'Фэнтези',
        Category.scifi => 'Фантастика',
        Category.detective => 'Детектив',
        Category.adventure => 'Приключения',
      };
}

class Book {
  final String id;
  final String title;
  final String subtitle;
  final Category category;
  final String? description;
  final int? year;
  final String color; // цвет обложки строкой без альфы, например '5C6BC0'
  final List<String> tags;

  const Book({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.description,
    this.year,
    this.color = '5C6BC0',
    this.tags = const [],
  });

  /// Превращение документа Firestore в модель, id берём из doc.id.
  factory Book.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Book(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      category:
          Category.values.asNameMap()[data['category'] as String?] ??
              Category.classic,
      description: data['description'] as String?,
      year: (data['year'] as num?)?.toInt(),
      color: data['color'] as String? ?? '5C6BC0',
      tags: (data['tags'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }

  /// Обратное превращение модели в Map — для записи в Firestore.
  /// id не пишем: его выдаёт Firestore.
  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'category': category.name,
        'description': description ?? '',
        'year': year,
        'tags': tags,
        'color': color,
      };
}
