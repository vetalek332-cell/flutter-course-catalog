import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель одного элемента каталога — книги.
/// Умеет превращаться из документа Firestore и обратно.

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
  final DateTime? createdAt;

  const Book({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.description,
    this.year,
    this.color = '5C6BC0',
    this.tags = const [],
    this.createdAt,
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
      createdAt: _parseDate(data['createdAt']),
    );
  }

  /// createdAt может прийти Timestamp'ом или строкой ISO.
  static DateTime? _parseDate(Object? value) => switch (value) {
        Timestamp timestamp => timestamp.toDate(),
        String string => DateTime.tryParse(string),
        _ => null,
      };

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

  static const Object _unset = Object();

  Book copyWith({
    String? id,
    String? title,
    String? subtitle,
    Object? category = _unset,
    Object? description = _unset,
    Object? year = _unset,
    Object? tags = _unset,
    Object? color = _unset,
    Object? createdAt = _unset,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category == _unset ? this.category : category as Category,
      description:
          description == _unset ? this.description : description as String?,
      year: year == _unset ? this.year : year as int?,
      tags: tags == _unset ? this.tags : tags as List<String>,
      color: color == _unset ? this.color : color as String,
      createdAt:
          createdAt == _unset ? this.createdAt : createdAt as DateTime?,
    );
  }
}
