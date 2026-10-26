// ЗАГЛУШКА! Файл создан вручную, чтобы проект компилировался без настройки.
//
// Запустите в корне проекта:
//   flutterfire configure --project=<id-вашего-проекта> --platforms=android,web
// и flutterfire перезапишет этот файл настоящими значениями вашего Firebase.
//
// Файл коммитится в репозиторий (это не секрет, письмо GitHub Possible valid
// secrets detected — ложное срабатывание, закрыть как False positive).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-ЗАМЕНИ-МЕНЯ-flutterfire-configure',
    appId: '1:000000000000:android:0000000000000000000000',
    projectId: 'catalog-00000',
    messagingSenderId: '000000000000',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-ЗАМЕНИ-МЕНЯ-flutterfire-configure',
    appId: '1:000000000000:ios:0000000000000000000000',
    projectId: 'catalog-00000',
    messagingSenderId: '000000000000',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-ЗАМЕНИ-МЕНЯ-flutterfire-configure',
    appId: '1:000000000000:macos:0000000000000000000000',
    projectId: 'catalog-00000',
    messagingSenderId: '000000000000',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA-ЗАМЕНИ-МЕНЯ-flutterfire-configure',
    appId: '1:000000000000:windows:0000000000000000000000',
    projectId: 'catalog-00000',
    messagingSenderId: '000000000000',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyA-ЗАМЕНИ-МЕНЯ-flutterfire-configure',
    appId: '1:000000000000:linux:0000000000000000000000',
    projectId: 'catalog-00000',
    messagingSenderId: '000000000000',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-ЗАМЕНИ-МЕНЯ-flutterfire-configure',
    appId: '1:000000000000:web:0000000000000000000000',
    projectId: 'catalog-00000',
    messagingSenderId: '000000000000',
  );
}
