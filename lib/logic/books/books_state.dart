import '../../domain/entities/book.dart';

/// Три состояния экрана каталога: загрузка, данные, ошибка.
sealed class BooksState {
  const BooksState();
}

/// Идёт загрузка каталога.
class BooksLoadInProgress extends BooksState {
  const BooksLoadInProgress();
}

/// Каталог загружен.
class BooksLoadSuccess extends BooksState {
  const BooksLoadSuccess(this.books);

  final List<Book> books;
}

/// Загрузить каталог не удалось.
class BooksLoadFailure extends BooksState {
  const BooksLoadFailure(this.message);

  final String message;
}
