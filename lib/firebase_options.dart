// Настройки Firebase проекта catalog-hw-8821
// (сгенерированы по данным flutterfire configure; тот же формат).
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_brtZVKQiQgZunV1I6DVWwr1ciJ_cfrM',
    appId: '1:175014335412:web:3fcf54295ea1982bf218e1',
    messagingSenderId: '175014335412',
    projectId: 'catalog-hw-8821',
    authDomain: 'catalog-hw-8821.firebaseapp.com',
    storageBucket: 'catalog-hw-8821.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwqLjuA3KuQ11ehclpZgb3IIt3GgGNnew',
    appId: '1:175014335412:android:3b70ade62986e7a6f218e1',
    messagingSenderId: '175014335412',
    projectId: 'catalog-hw-8821',
    storageBucket: 'catalog-hw-8821.firebasestorage.app',
  );
}
