# Каталог книг — Университет Иннополис

Учебный проект курса «Принципы управления РПП. Раздел 1. Разработка приложений на Flutter».
Тема каталога — **книги**.

## Ветки репозитория

| Ветка | Задание | Как запустить |
|-------|---------|---------------|
| `main` | Стартовый проект (счётчик с первого занятия) | `flutter run` |
| `hw1` | ДЗ 1. Шесть виджетов | `flutter run -t lib/hw1/main.dart` |
| `hw2` | ДЗ 2. Экран списка каталога | `flutter run -t lib/hw2/main.dart` |
| `hw3` | ДЗ 3. Модель, структура, лайки | `flutter run` |
| `hw4` | ДЗ 4. Каталог с сервера (MockAPI, GET/POST) | `flutter run` |
| `hw5` | ДЗ 5. Firebase: вход и каталог в Firestore | `flutter run` |
| `project` | Финальная аттестация: BLoC + Firebase + опции | `flutter run` |

## Подготовка проекта

Платформенные папки (`android/`, `ios/`, `web/`, ...) не хранятся в репозитории.
Чтобы восстановить их на своей машине, выполните в корне проекта:

```bash
flutter create .
flutter pub get
```

## ДЗ 4: настройка MockAPI

См. файл `mockapi/books.json` в ветке `hw4`. Адрес сервера подставляется
в `lib/data/books_api.dart` в той же ветке.

## ДЗ 5: подключение Firebase

1. Создайте проект на [console.firebase.google.com](https://console.firebase.google.com)
   (тариф Spark, карта не нужна).
2. Подключите Flutter-проект командой (из корня, там где `pubspec.yaml`):

   ```bash
   flutterfire configure --project=<id-вашего-проекта> --platforms=android,web
   ```

   Файл `firebase_options.dart` перезапишется настоящими значениями.
3. В консоли Firebase включите **Authentication → Sign-in method → Email/Password**.
4. Создайте **Firestore Database** (регион любой, режим продакшена).
5. Вкладка **Firestore Database → Rules**: вставьте содержимое файла
   [`firestore.rules`](firestore.rules) и нажмите Publish:

   ```
   allow read, write: if request.auth != null;
   ```

6. Запустите приложение:

   ```bash
   flutter run
   ```

7. Зарегистрируйтесь тестовой почтой (`test1@test.com`, пароль от 6 символов).
   Если коллекция `books` пустая — на экране появится кнопка
   «Заполнить демо-данными» (12 книг одним батчем), либо добавляйте элементы
   формой, как требует задание.

### Возможные ошибки

- `permission-denied` — не выполнен вход или не опубликовано правило.
- Ошибка `invalid-api-key` при запуске — `firebase_options.dart` всё ещё
  содержит заглушку, выполните `flutterfire configure`.
- Письмо GitHub Possible valid secrets detected про ключ в
  `firebase_options.dart` — не секрет: Security → Secret scanning → закрыть
  как False positive.

### Что где лежит (ДЗ 5)

```
lib/
├── main.dart                       # инициализация Firebase, AuthGate
├── firebase_options.dart           # настройки проекта (генерирует flutterfire)
├── domain/entities/book.dart       # модель: fromFirestore (id из doc.id) и toJson
└── ui/
    ├── screens/login_screen.dart   # вход и регистрация, ошибки e.code видны на экране
    ├── screens/catalog_screen.dart # каталог через snapshots() + StreamBuilder
    └── widgets/book_card.dart      # карточка книги
```
