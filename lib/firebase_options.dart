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
    apiKey: 'AIzaSyBQcv_vfU-BUws-ArfCKiC_lbWkr8AZeZI',
    appId: '1:920476433685:web:36d757f6ccef932824fd1c',
    messagingSenderId: '920476433685',
    projectId: 'ajsmensajes',
    authDomain: 'ajsmensajes.firebaseapp.com',
    storageBucket: 'ajsmensajes.firebasestorage.app',
    measurementId: 'G-TQSBYEH0E0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJu5I1MskPCzxxAS3y2eFU_IXGfdJ73SA',
    appId: '1:920476433685:android:6fb10d3597fa55cf24fd1c',
    messagingSenderId: '920476433685',
    projectId: 'ajsmensajes',
    storageBucket: 'ajsmensajes.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1c9DunyX-yQM8-XWXKA6f9rdfR-0ZMm0',
    appId: '1:920476433685:ios:0911dbb40b6fd79624fd1c',
    messagingSenderId: '920476433685',
    projectId: 'ajsmensajes',
    storageBucket: 'ajsmensajes.firebasestorage.app',
    iosBundleId: 'com.example.pruebaChat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA1c9DunyX-yQM8-XWXKA6f9rdfR-0ZMm0',
    appId: '1:920476433685:ios:0911dbb40b6fd79624fd1c',
    messagingSenderId: '920476433685',
    projectId: 'ajsmensajes',
    storageBucket: 'ajsmensajes.firebasestorage.app',
    iosBundleId: 'com.example.pruebaChat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBQcv_vfU-BUws-ArfCKiC_lbWkr8AZeZI',
    appId: '1:920476433685:web:040a74e39bd8d53e24fd1c',
    messagingSenderId: '920476433685',
    projectId: 'ajsmensajes',
    authDomain: 'ajsmensajes.firebaseapp.com',
    storageBucket: 'ajsmensajes.firebasestorage.app',
    measurementId: 'G-TF1REQ3M9F',
  );

}