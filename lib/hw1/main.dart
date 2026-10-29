import 'package:flutter/material.dart';

/// Домашнее задание 1 — «Шесть виджетов».
/// Тема каталога: книги.
///
/// Раскладка экрана собрана заранее (как в шаблоне занятия):
/// редактируются только функции task1–task6 ниже.
void main() => runApp(const HomeworkApp());

class HomeworkApp extends StatelessWidget {
  const HomeworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ДЗ 1',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C6BC0)),
      ),
      home: const HomeworkScaffold(),
    );
  }
}

class HomeworkScaffold extends StatelessWidget {
  const HomeworkScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ДЗ 1. Шесть виджетов')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Задание 1. Заголовок
              task1(),
              const SizedBox(height: 12),
              // Задания 2 и 3 в одном ряду
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  task3(),
                  const SizedBox(width: 12),
                  Expanded(child: task2()),
                ],
              ),
              const SizedBox(height: 24),
              // Задания 4 и 5 — кнопки
              Row(
                children: [
                  task4(),
                  const SizedBox(width: 12),
                  task5(),
                ],
              ),
              const SizedBox(height: 24),
              // Задание 6. Фотография в стиле Polaroid
              task6(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1. Заголовок: крупный жирный текст чёрного цвета,
/// обрезается в одну строку, если не помещается.
Widget task1() {
  return const Text(
    'Каталог книг — домашнее задание номер один',
    style: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

/// 2. Подпись: небольшой нежирный курсивный текст белого цвета
/// на тёмно-серой подложке с закруглениями, обрезается в две строки.
Widget task2() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF424242),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      'Подпись с описанием карточки книги, которая занимает до двух строк и обрезается многоточием',
      style: TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Colors.white,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

/// 3. Иконка: с цветом и размером.
Widget task3() {
  return const Icon(
    Icons.menu_book,
    color: Color(0xFF5C6BC0),
    size: 56,
  );
}

/// 4. Кнопка с иконкой избранного: большая красная иконка-сердце
/// без фона, при нажатии пишет в консоль «Вы добавили в избранное».
Widget task4() {
  return IconButton(
    icon: const Icon(
      Icons.favorite,
      color: Colors.red,
      size: 48,
    ),
    onPressed: () => debugPrint('Вы добавили в избранное'),
  );
}

/// 5. Кнопка «Подробнее»: кнопка с текстом и обводкой,
/// при нажатии пишет в консоль «Узнать детали».
Widget task5() {
  return OutlinedButton(
    onPressed: () => debugPrint('Узнать детали'),
    child: const Text('Подробнее'),
  );
}

/// 6. Изображение в стиле Polaroid: чёрная обводка,
/// внутри белая подложка и фото из интернета.
Widget task6() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 4),
      borderRadius: BorderRadius.circular(4),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Image.network(
        'https://picsum.photos/seed/catalog/400/300',
        width: 240,
        height: 180,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: 240,
            height: 180,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 240,
            height: 180,
            color: const Color(0xFFEEEEEE),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 48, color: Color(0xFF9E9E9E)),
                SizedBox(height: 8),
                Text(
                  'Не удалось загрузить фото\n(нужен интернет или VPN)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
