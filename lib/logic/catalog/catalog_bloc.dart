import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../domain/entities/book.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

/// Управляет данными каталога: подписки на потоки Firestore,
/// лайки, фильтры, сортировка, добавление, изменение и удаление.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required CatalogRepository repository, required String uid})
      : _repository = repository,
        _uid = uid,
        super(const CatalogState()) {
    on<CatalogStarted>(_onStarted);
    on<CatalogRefreshRequested>(_onRefreshRequested);
    on<CatalogQueryChanged>(_onQueryChanged);
    on<CatalogCategorySelected>(_onCategorySelected);
    on<CatalogFavoritesOnlyToggled>(_onFavoritesOnlyToggled);
    on<CatalogSortSelected>(_onSortSelected);
    on<CatalogLikeToggled>(_onLikeToggled);
    on<CatalogBookAdded>(_onBookAdded);
    on<CatalogBookUpdated>(_onBookUpdated);
    on<CatalogBookDeleted>(_onBookDeleted);
    on<CatalogDemoDataRequested>(_onDemoDataRequested);
    on<_BooksUpdated>(_onBooksUpdated);
    on<_FavoritesUpdated>(_onFavoritesUpdated);
    on<CatalogStreamFailed>(_onStreamFailed);
  }

  final CatalogRepository _repository;
  final String _uid;

  StreamSubscription<List<Book>>? _booksSubscription;
  StreamSubscription<Set<String>>? _favoritesSubscription;

  /// Подписка на каталог и избранное пользователя.
  void _subscribe() {
    _booksSubscription?.cancel();
    _favoritesSubscription?.cancel();
    _booksSubscription = _repository.booksStream().listen(
          (books) => add(_BooksUpdated(books)),
          onError: (Object error) =>
              add(CatalogStreamFailed(error.toString())),
        );
    _favoritesSubscription = _repository.favoritesStream(_uid).listen(
          (likedIds) => add(_FavoritesUpdated(likedIds)),
          onError: (Object error) =>
              add(CatalogStreamFailed(error.toString())),
        );
  }

  Future<void> _onStarted(
    CatalogStarted event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(status: CatalogStatus.loading));
    _subscribe();
  }

  /// Кнопка «Обновить»: переподключаемся к потокам заново.
  Future<void> _onRefreshRequested(
    CatalogRefreshRequested event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(status: CatalogStatus.loading));
    _subscribe();
  }

  Future<void> _onQueryChanged(
    CatalogQueryChanged event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onCategorySelected(
    CatalogCategorySelected event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(categoryFilter: event.category));
  }

  Future<void> _onFavoritesOnlyToggled(
    CatalogFavoritesOnlyToggled event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(favoritesOnly: !state.favoritesOnly));
  }

  Future<void> _onSortSelected(
    CatalogSortSelected event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(sort: event.sort));
  }

  Future<void> _onLikeToggled(
    CatalogLikeToggled event,
    Emitter<CatalogState> emit,
  ) async {
    // Оптимистичное состояние: поток из Firestore подтвердит его сразу же.
    final likedIds = {...state.likedIds};
    if (!likedIds.remove(event.bookId)) {
      likedIds.add(event.bookId);
    }
    emit(state.copyWith(likedIds: likedIds));
    try {
      await _repository.toggleLike(uid: _uid, bookId: event.bookId);
    } catch (_) {
      // Ошибка записи не ломает экран: поток вернёт актуальное состояние.
    }
  }

  Future<void> _onBookAdded(
    CatalogBookAdded event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      await _repository.addBook(event.book);
    } catch (error) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        error: 'Не удалось добавить элемент: $error',
      ));
    }
  }

  Future<void> _onBookUpdated(
    CatalogBookUpdated event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      await _repository.updateBook(event.book);
    } catch (error) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        error: 'Не удалось сохранить изменения: $error',
      ));
    }
  }

  Future<void> _onBookDeleted(
    CatalogBookDeleted event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      await _repository.deleteBook(event.bookId);
    } catch (error) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        error: 'Не удалось удалить элемент: $error',
      ));
    }
  }

  Future<void> _onDemoDataRequested(
    CatalogDemoDataRequested event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      await _repository.addDemoData();
    } catch (error) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        error: 'Не удалось заполнить демо-данные: $error',
      ));
    }
  }

  Future<void> _onBooksUpdated(
    _BooksUpdated event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(status: CatalogStatus.loaded, books: event.books));
  }

  Future<void> _onFavoritesUpdated(
    _FavoritesUpdated event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(likedIds: event.likedIds));
  }

  Future<void> _onStreamFailed(
    CatalogStreamFailed event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(status: CatalogStatus.error, error: event.message));
  }

  @override
  Future<void> close() {
    _booksSubscription?.cancel();
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
