import 'package:firebase_core/firebase_core.dart';

class FirebaseCoreInitializer {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        appId: '1:517925968957:android:4c2c8622b4d51718e71e54',
        apiKey: 'AIzaSyD_psyzQGaIPEZdAcJWISw6A7wtXEUnmGU',
        projectId: 'study-timer-1',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        authDomain: 'YOUR_AUTH_DOMAIN',
        databaseURL: 'YOUR_DATABASE_URL',
        storageBucket: 'YOUR_STORAGE_BUCKET',
      ),
    );
  }
}

