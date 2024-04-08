import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/provider/word_provider.dart';
import 'package:memo_words/view/word_card_page.dart';
import 'package:memo_words/view/word_create_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(wordViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('英単語暗記アプリ'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: Text("単語を追加する"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WordCreatePage()),
                );
              },
            ),
            ElevatedButton(
              child: Text("単語テスト"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordCardPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
