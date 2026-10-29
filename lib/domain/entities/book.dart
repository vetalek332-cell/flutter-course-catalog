// Модель одного элемента каталога — книги.

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
  final int id;
  final String title;
  final String subtitle;
  final Category category;
  final String? description;
  final int? year;
  final int color; // цвет обложки, например 0xFF5C6BC0

  const Book({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.description,
    this.year,
    this.color = 0xFF5C6BC0,
  });
}
