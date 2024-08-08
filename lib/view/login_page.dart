import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/provider/auth_view_model_provider.dart';
import 'package:memo_words/view/home_page.dart';

class LoginPage extends ConsumerWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text;
                final password = _passwordController.text;

                ref
                    .read(authViewModelProvider.notifier)
                    .loginOrCreateAccount(email, password)
                    .then((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage(false)),
                  );
                }).catchError((error) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('エラー'),
                      content: Text(error.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                });
              },
              child: const Text('ログイン / 新規登録'),
            ),
          ],
        ),
      ),
    );
  }
}
