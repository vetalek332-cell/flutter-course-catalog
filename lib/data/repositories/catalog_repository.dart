import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/book.dart';
import '../seed_data.dart';

/// Единая точка доступа к данным каталога в Firestore.
/// Bloc обращается к репозиторию, виджеты к Firebase напрямую не обращаются.
class CatalogRepository {
  CatalogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String booksCollection = 'books';

  CollectionReference<Map<String, dynamic>> get _books =>
      _firestore.collection(booksCollection);

  /// Поток всех книг каталога — обновляется в реальном времени.
  Stream<List<Book>> booksStream() {
    return _books.snapshots().map(
          (snapshot) => snapshot.docs.map(Book.fromFirestore).toList(),
        );
  }

  /// Поток id избранных элементов конкретного пользователя.
  Stream<Set<String>> favoritesStream(String uid) {
    final favorites =
        _firestore.collection('users').doc(uid).collection('favorites');
    return favorites
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  /// Лайк привязан к пользователю: документ `users/<uid>/favorites/<id книги>`.
  Future<void> toggleLike({required String uid, required String bookId}) async {
    final doc = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(bookId);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await doc.delete();
    } else {
      await doc.set(const {'liked': true});
    }
  }

  /// Добавление: создаёт документ в Firestore, дата — время сервера.
  Future<void> addBook(Book book) {
    return _books.add({
      ...book.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBook(Book book) {
    return _books.doc(book.id).update(book.toJson());
  }

  Future<void> deleteBook(String bookId) {
    return _books.doc(bookId).delete();
  }

  /// Заполняет пустой каталог демо-данными (12 книг) одним батчем.
  Future<void> addDemoData() async {
    final batch = _firestore.batch();
    for (var i = 0; i < demoBooks.length; i++) {
      final ref = _books.doc();
      batch.set(ref, {
        ...demoBooks[i].toJson(),
        'createdAt': DateTime.now()
            .subtract(Duration(days: demoBooks.length - i)),
      });
    }
    return batch.commit();
  }
}
