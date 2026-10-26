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

  /// Превращение JSON с сервера в модель.
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category:
          Category.values.asNameMap()[json['category'] as String?] ??
              Category.classic,
      description: json['description'] as String?,
      year: (json['year'] as num?)?.toInt(),
      color: json['color'] as String? ?? '5C6BC0',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }

  /// Обратное превращение модели в Map — для отправки на сервер.
  /// id не отправляем: его выдаёт сервер.
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
