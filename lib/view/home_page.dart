import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/provider/word_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(wordViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('英単語暗記アプリ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(labelText: '英単語を追加'),
              onFieldSubmitted: (value) {
                ref.read(wordViewModelProvider.notifier).addWord(value, '意味');
              },
            ),
          ),
          Expanded(
            child: words.isEmpty
                ? const Center(child: Text('単語がありません'))
                : ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return ListTile(
                        title: Text(word.word),
                        subtitle: Text(word.meaning),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
