
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
    apiKey: 'AIzaSyAqjQBktLWtcJZ_E3OR4qh9Ij9lX0q63-o',
    appId: '1:657028442844:web:3eede6148d40a5f37a2219',
    messagingSenderId: '657028442844',
    projectId: 'vehicle-rental-app-firebase',
    authDomain: 'vehicle-rental-app-firebase.firebaseapp.com',
    storageBucket: 'vehicle-rental-app-firebase.firebasestorage.app',
    measurementId: 'G-6VPXPH4Z9E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8Qgr4vNPFP3bso4Dv7b3xSYXanaUw-z0',
    appId: '1:657028442844:android:4131daa0f595fd5c7a2219',
    messagingSenderId: '657028442844',
    projectId: 'vehicle-rental-app-firebase',
    storageBucket: 'vehicle-rental-app-firebase.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCy77KAGISKOQrINUVQV8KsqayzbcLWxMI',
    appId: '1:657028442844:ios:3e82fc0cd04100717a2219',
    messagingSenderId: '657028442844',
    projectId: 'vehicle-rental-app-firebase',
    storageBucket: 'vehicle-rental-app-firebase.firebasestorage.app',
    iosBundleId: 'com.example.flexrideNew',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCy77KAGISKOQrINUVQV8KsqayzbcLWxMI',
    appId: '1:657028442844:ios:3e82fc0cd04100717a2219',
    messagingSenderId: '657028442844',
    projectId: 'vehicle-rental-app-firebase',
    storageBucket: 'vehicle-rental-app-firebase.firebasestorage.app',
    iosBundleId: 'com.example.flexrideNew',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAqjQBktLWtcJZ_E3OR4qh9Ij9lX0q63-o',
    appId: '1:657028442844:web:a900cf51abcb77897a2219',
    messagingSenderId: '657028442844',
    projectId: 'vehicle-rental-app-firebase',
    authDomain: 'vehicle-rental-app-firebase.firebaseapp.com',
    storageBucket: 'vehicle-rental-app-firebase.firebasestorage.app',
    measurementId: 'G-Z4VTK32HWC',
  );
}