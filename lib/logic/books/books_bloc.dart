import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/demo_books.dart';
import '../../domain/entities/book.dart';
import 'books_event.dart';
import 'books_state.dart';

/// Управляет данными каталога: подписка на snapshots() коллекции books,
/// добавление элементов и заполнение демо-данными.
/// Виджеты не обращаются к Firestore — только к этому Bloc.
class BooksBloc extends Bloc<BooksEvent, BooksState> {
  BooksBloc() : super(const BooksLoadInProgress()) {
    on<BooksLoadRequested>(_onLoadRequested);
  }

  /// Поток каталога: приходит новым событием → новое состояние.
  /// При ошибке (например, чтение запрещено в Rules) — состояние ошибки.
  Future<void> _onLoadRequested(
    BooksLoadRequested event,
    Emitter<BooksState> emit,
  ) async {
    emit(const BooksLoadInProgress());
    await emit.forEach(
      FirebaseFirestore.instance.collection('books').snapshots(),
      onData: (snapshot) => BooksLoadSuccess(
        snapshot.docs.map(Book.fromFirestore).toList(),
      ),
      onError: (error, stackTrace) =>
          const BooksLoadFailure('Не удалось загрузить каталог'),
    );
  }

  /// Добавление: создаёт документ в Firestore,
  /// список обновится сам через подписку snapshots().
  Future<void> addBook(Book book) {
    return FirebaseFirestore.instance.collection('books').add(book.toJson());
  }

  /// Заполняет пустую коллекцию 12 книгами одним батчем.
  Future<void> seedDemoData() async {
    final store = FirebaseFirestore.instance;
    final batch = store.batch();
    for (final book in demoBooks) {
      batch.set(store.collection('books').doc(), book.toJson());
    }
    await batch.commit();
  }
}
