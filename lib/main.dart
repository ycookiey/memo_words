import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/view/home_page.dart';
import 'package:memo_words/view/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final shuffledProvider = StateProvider<bool>((ref) => false);

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo Words',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }
            if (snapshot.hasData) {
              // サインイン済 → ホーム画面へ
              return const HomePage(false);
            }
            // 未サインイン → サインイン画面へ
            return LoginPage();
          },
        ),
      );
  }
}
