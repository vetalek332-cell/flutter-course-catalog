/// События BLoC каталога.
sealed class BooksEvent {
  const BooksEvent();
}

/// Запустить загрузку каталога (первая загрузка и кнопка «Обновить»).
class BooksLoadRequested extends BooksEvent {
  const BooksLoadRequested();
}
