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
flutter run
```

## ДЗ 4: настройка MockAPI

1. Зайдите на [mockapi.io](https://mockapi.io) и войдите через GitHub.
2. Создайте проект (например, `catalog`), откройте его — сверху будет адрес вида
   `https://<ваш-токен>.mockapi.io`.
3. В проекте нажмите **New resource**, имя — `books`. Схема (Schema):

   | Поле | Тип |
   |------|-----|
   | title | String |
   | subtitle | String |
   | category | String |
   | description | String |
   | color | String |
   | year | Number |
   | tags | Array |

   Поле `id` оставьте, остальные поля-примеры удалите.
4. Рядом с ресурсом нажмите **Data**, удалите содержимое и вставьте целиком
   массив из файла [`mockapi/books.json`](mockapi/books.json) (12 книг).
   Сохраните.
5. Проверьте в браузере `https://<ваш-токен>.mockapi.io/books` — должен прийти
   JSON-массив.
6. Подставьте свой адрес в константу `baseUrl` в начале файла
   `lib/data/books_api.dart`.
