part of 'catalog_bloc.dart';

abstract class CatalogEvent {
  const CatalogEvent();
}

/// Загрузить каталог (подписаться на данные).
class CatalogStarted extends CatalogEvent {
  const CatalogStarted();
}

/// Перезапустить загрузку после ошибки (кнопка «Обновить»).
class CatalogRefreshRequested extends CatalogEvent {
  const CatalogRefreshRequested();
}

/// Поиск: меняется при вводе текста.
class CatalogQueryChanged extends CatalogEvent {
  const CatalogQueryChanged(this.query);

  final String query;
}

/// Фильтр по категории; null — сбросить («Все»).
class CatalogCategorySelected extends CatalogEvent {
  const CatalogCategorySelected(this.category);

  final Category? category;
}

/// Переключатель «Только избранные».
class CatalogFavoritesOnlyToggled extends CatalogEvent {
  const CatalogFavoritesOnlyToggled();
}

/// Выбор сортировки.
class CatalogSortSelected extends CatalogEvent {
  const CatalogSortSelected(this.sort);

  final CatalogSort sort;
}

/// Лайк/дизлайк элемента.
class CatalogLikeToggled extends CatalogEvent {
  const CatalogLikeToggled(this.bookId);

  final String bookId;
}

/// Добавление нового элемента.
class CatalogBookAdded extends CatalogEvent {
  const CatalogBookAdded(this.book);

  final Book book;
}

/// Сохранение изменений существующего элемента.
class CatalogBookUpdated extends CatalogEvent {
  const CatalogBookUpdated(this.book);

  final Book book;
}

/// Удаление элемента.
class CatalogBookDeleted extends CatalogEvent {
  const CatalogBookDeleted(this.bookId);

  final String bookId;
}

/// Заполнить пустой каталог демо-данными.
class CatalogDemoDataRequested extends CatalogEvent {
  const CatalogDemoDataRequested();
}

// ——— Внутренние события: данные приходят из потоков Firestore ———

class _BooksUpdated extends CatalogEvent {
  const _BooksUpdated(this.books);

  final List<Book> books;
}

class _FavoritesUpdated extends CatalogEvent {
  const _FavoritesUpdated(this.likedIds);

  final Set<String> likedIds;
}

/// Поток Firestore сообщил об ошибке (например, нет интернета).
class CatalogStreamFailed extends CatalogEvent {
  const CatalogStreamFailed(this.message);

  final String message;
}
