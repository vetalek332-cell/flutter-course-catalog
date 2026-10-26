import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';

/// Иконка для категории книги.
IconData categoryIcon(Category category) => switch (category) {
      Category.classic => Icons.menu_book,
      Category.fantasy => Icons.auto_stories,
      Category.scifi => Icons.rocket_launch,
      Category.detective => Icons.search,
      Category.adventure => Icons.explore,
    };
