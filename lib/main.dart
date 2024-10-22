import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator(
    LocatorConfig(
      authority: const String.fromEnvironment("AUTHORITY"),
      googleMapApiKey: const String.fromEnvironment("GOOGLE_MAP_API_KEY"),
    ),
  );

  await Firebase.initializeApp(
    options: switch (defaultTargetPlatform) {
      (TargetPlatform.android) => const FirebaseOptions(
          apiKey: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_APIKEY"),
          appId: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_APP_ID"),
          messagingSenderId: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_MESSAGING_SENDER_ID"),
          projectId: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_PROJECT_ID"),
          storageBucket: String.fromEnvironment("FIREBASE_OPTIONS_ANDROID_STORAGE_BUCKET"),
        ),
      (TargetPlatform.iOS) => const FirebaseOptions(
          apiKey: String.fromEnvironment("FIREBASE_OPTIONS_IOS_APIKEY"),
          appId: String.fromEnvironment("FIREBASE_OPTIONS_IOS_APP_ID"),
          messagingSenderId: String.fromEnvironment("FIREBASE_OPTIONS_IOS_MESSAGING_SENDER_ID"),
          projectId: String.fromEnvironment("FIREBASE_OPTIONS_IOS_PROJECT_ID"),
          storageBucket: String.fromEnvironment("FIREBASE_OPTIONS_IOS_STORAGE_BUCKET"),
          iosBundleId: String.fromEnvironment("FIREBASE_OPTIONS_IOS_BUNDLE_ID"),
        ),
      _ => throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        ),
    },
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const App());
}
