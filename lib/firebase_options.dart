// NOTE: Native Firebase SDK is not in pubspec.yaml because the app uses pure
// REST APIs in lib/data/firebase_rest_service.dart.
// If you configure native Firebase in the future, uncomment the code below and
// add firebase_core to pubspec.yaml.
/*
// Generated for NOOR AI Companion Firebase project: noor-ai-916ed
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAw_Az1vdkdXANXe22jw1dIO__XM2fTOKc',
    appId: '1:1036624378483:android:044d675bbd6caba80c0806',
    messagingSenderId: '1036624378483',
    projectId: 'noor-ai-916ed',
    storageBucket: 'noor-ai-916ed.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAw_Az1vdkdXANXe22jw1dIO__XM2fTOKc',
    appId: '1:1036624378483:ios:PLACEHOLDER',
    messagingSenderId: '1036624378483',
    projectId: 'noor-ai-916ed',
    storageBucket: 'noor-ai-916ed.firebasestorage.app',
    iosBundleId: 'com.noorai.com',
  );
}
*/
