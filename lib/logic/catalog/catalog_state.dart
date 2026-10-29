part of 'catalog_bloc.dart';

/// Явные состояния экрана каталога.
enum CatalogStatus { loading, loaded, error }

enum CatalogSort { byNewest, byTitle, byYear }

extension CatalogSortLabel on CatalogSort {
  String get label => switch (this) {
        CatalogSort.byNewest => 'Сначала новые',
        CatalogSort.byTitle => 'По названию',
        CatalogSort.byYear => 'По году издания',
      };
}

/// Sentinel, чтобы отличить «не менять фильтр» от «сбросить фильтр в null».
const Object _unsetCategory = Object();

class CatalogState {
  const CatalogState({
    this.status = CatalogStatus.loading,
    this.books = const [],
    this.likedIds = const {},
    this.query = '',
    this.categoryFilter,
    this.favoritesOnly = false,
    this.sort = CatalogSort.byNewest,
    this.error,
  });

  final CatalogStatus status;
  final List<Book> books;
  final Set<String> likedIds;
  final String query;

  /// null — фильтр по категории не выбран.
  final Category? categoryFilter;
  final bool favoritesOnly;
  final CatalogSort sort;
  final String? error;

  int get favoritesCount => likedIds.length;

  bool get hasActiveFilters =>
      favoritesOnly || categoryFilter != null || query.trim().isNotEmpty;

  /// Отфильтрованный и отсортированный список — считается на лету,
  /// отдельно не хранится. Фильтры сочетаются между собой.
  List<Book> get visibleBooks {
    var result = books;

    if (favoritesOnly) {
      result = result.where((book) => likedIds.contains(book.id)).toList();
    }

    final category = categoryFilter;
    if (category != null) {
      result = result.where((book) => book.category == category).toList();
    }

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      // Поиск без учёта регистра, фильтрация во время ввода.
      result = result
          .where((book) => book.title.toLowerCase().contains(q))
          .toList();
    }

    switch (sort) {
      case CatalogSort.byTitle:
        result.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case CatalogSort.byNewest:
        result.sort((a, b) => _compareDesc(
              a.createdAt?.millisecondsSinceEpoch,
              b.createdAt?.millisecondsSinceEpoch,
            ));
      case CatalogSort.byYear:
        result.sort((a, b) => _compareDesc(a.year, b.year));
    }

    return result;
  }

  CatalogState copyWith({
    CatalogStatus? status,
    List<Book>? books,
    Set<String>? likedIds,
    String? query,
    Object? categoryFilter = _unsetCategory,
    bool? favoritesOnly,
    CatalogSort? sort,
    String? error,
  }) {
    return CatalogState(
      status: status ?? this.status,
      books: books ?? this.books,
      likedIds: likedIds ?? this.likedIds,
      query: query ?? this.query,
      categoryFilter: categoryFilter == _unsetCategory
          ? this.categoryFilter
          : categoryFilter as Category?,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
      error: error ?? this.error,
    );
  }
}

/// Убывание: большее значение выше, null — в конце.
int _compareDesc(int? a, int? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}
