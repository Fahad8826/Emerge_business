// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyAqH6xC-XP8nJEi7Qnu1EbTd5ZfZUFWPk8',
    appId: '1:251632185451:web:901e841de52e1bba7f012e',
    messagingSenderId: '251632185451',
    projectId: 'emerge-fa3ce',
    authDomain: 'emerge-fa3ce.firebaseapp.com',
    storageBucket: 'emerge-fa3ce.firebasestorage.app',
    measurementId: 'G-DPPZH1C731',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_es27K21CeVZ639sbL41RIxZUrpK8JnU',
    appId: '1:251632185451:android:3a78191d9db939487f012e',
    messagingSenderId: '251632185451',
    projectId: 'emerge-fa3ce',
    storageBucket: 'emerge-fa3ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4HCkbbJk_wBKSsEMFV4VJdXf1W6p6gQg',
    appId: '1:251632185451:ios:b1d2a0d2cc75694c7f012e',
    messagingSenderId: '251632185451',
    projectId: 'emerge-fa3ce',
    storageBucket: 'emerge-fa3ce.firebasestorage.app',
    iosBundleId: 'com.example.emergeBusiness',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA4HCkbbJk_wBKSsEMFV4VJdXf1W6p6gQg',
    appId: '1:251632185451:ios:b1d2a0d2cc75694c7f012e',
    messagingSenderId: '251632185451',
    projectId: 'emerge-fa3ce',
    storageBucket: 'emerge-fa3ce.firebasestorage.app',
    iosBundleId: 'com.example.emergeBusiness',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAqH6xC-XP8nJEi7Qnu1EbTd5ZfZUFWPk8',
    appId: '1:251632185451:web:e8de728f5ef908c47f012e',
    messagingSenderId: '251632185451',
    projectId: 'emerge-fa3ce',
    authDomain: 'emerge-fa3ce.firebaseapp.com',
    storageBucket: 'emerge-fa3ce.firebasestorage.app',
    measurementId: 'G-RXBRVWH4N5',
  );
}
