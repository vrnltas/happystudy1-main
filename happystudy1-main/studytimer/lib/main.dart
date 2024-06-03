import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studytimer/auth/verification_screen.dart';
import 'package:studytimer/firebase/firebase_options.dart';
import 'package:studytimer/pages/homepage.dart';
import 'package:studytimer/screens/welcome/welcome_screen.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize time zone data
  tzdata.initializeTimeZones();

  // Set local time zone
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/logo');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

   // Inisialisasi Firebase dengan konfigurasi yang Anda tentukan di firebase_options
    await Firebase.initializeApp(
      options: FirebaseOptionsProvider.get(),
        );
    
    // Activate App Check with the debug provider
    FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.instance;
    await firebaseAppCheck.activate(
    androidProvider: AndroidProvider.debug,
    );

  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); 

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey, 
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const AuthenticationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }


class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong!'));
        } else if (snapshot.data == null) {
          return const WelcomeScreen();
        } else {
          final user = snapshot.data!;
          final hasCompletedVerificationFuture = user.getIdTokenResult().then((result) => result.claims?['hasCompletedVerification'] == true);

          return FutureBuilder<bool>(
            future: hasCompletedVerificationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong!'));
              } else if (!snapshot.hasData || !snapshot.data!) {
                return const WelcomeScreen();
              } else if (!user.emailVerified) {
                return VerificationScreen(
                  user: user,
                );
              } else {
                return const HomePage();
              }
            },
          );
        }
      },
    );
  }
}