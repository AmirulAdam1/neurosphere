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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDF3UtTJWM46GFMf9h7UHwUw9R62nhgCdE',
    appId: '1:968185374662:web:8378aad7008cbdc6d074c7',
    messagingSenderId: '968185374662',
    projectId: 'neurosphere-7cdab',
    authDomain: 'neurosphere-7cdab.firebaseapp.com',
    storageBucket: 'neurosphere-7cdab.firebasestorage.app',
    measurementId: 'G-K8BJK60HE2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2HZc3_qc_oLty2RCXYNFTfDOKBj91Pu4',
    appId: '1:968185374662:android:b050eca6a7e0b2edd074c7',
    messagingSenderId: '968185374662',
    projectId: 'neurosphere-7cdab',
    storageBucket: 'neurosphere-7cdab.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDosgkI9CHvdHgbtBRHD-TB73Mt683Ss-Y',
    appId: '1:968185374662:ios:6324bb4e0ce94321d074c7',
    messagingSenderId: '968185374662',
    projectId: 'neurosphere-7cdab',
    storageBucket: 'neurosphere-7cdab.firebasestorage.app',
    iosBundleId: 'com.example.neurosphere',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDF3UtTJWM46GFMf9h7UHwUw9R62nhgCdE',
    appId: '1:968185374662:web:8e8d67f44d658a19d074c7',
    messagingSenderId: '968185374662',
    projectId: 'neurosphere-7cdab',
    authDomain: 'neurosphere-7cdab.firebaseapp.com',
    storageBucket: 'neurosphere-7cdab.firebasestorage.app',
    measurementId: 'G-HKGL7SZ020',
  );
}
