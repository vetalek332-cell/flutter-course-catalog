import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/entities/book.dart';

/// Базовый адрес вашего API на MockAPI.
/// Замените ВАШ-ТОКЕН на свой (адрес вида https://abc123.mockapi.io).
const baseUrl = 'https://ВАШ-ТОКЕН.mockapi.io';

/// Запросы к серверу MockAPI: загрузка каталога и добавление элемента.
class BooksApi {
  /// GET — получить список всех элементов.
  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));
    if (response.statusCode != 200) {
      throw Exception('Статус ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List;
    return list
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST — создать элемент. В теле JSON без id,
  /// в ответе сервера элемент уже с id.
  Future<Book> createBook(Book book) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(book.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Статус ${response.statusCode}');
    }
    return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
