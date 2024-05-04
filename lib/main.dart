import 'package:chatapp/screen/chat_screen.dart';
import 'package:chatapp/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lightBlue,
        primary: const Color.fromARGB(255, 18, 152, 214),
      )),
      title: 'Flutter Demo',
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapchot) {
          if (snapchot.hasData) {
            print("obaida is surfing");
            print(snapchot.data);
            return const ChatScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
