import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neurosphere/firebase_options.dart';
import 'package:neurosphere/views/login_view.dart';
import 'package:neurosphere/views/register_view.dart';
import 'package:neurosphere/views/verify_email_view.dart';
import 'package:neurosphere/views/chat_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for mobile
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neurosphere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // Using StreamBuilder to handle FirebaseAuth state changes dynamically
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user != null) {
              if (user.emailVerified) {
                return const ChatScreen(); // Navigate to the chat screen if the user is logged in and email is verified
              } else {
                return const VerifyEmailView(); // Navigate to email verification if the user is logged in but email isn't verified
              }
            } else {
              return const LoginView(); // Navigate to the login screen if the user is not logged in
            }
          } else {
            return const CircularProgressIndicator(); // Show loading while checking the authentication state
          }
        },
      ),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    );
  }
}
