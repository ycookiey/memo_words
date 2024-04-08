import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/provider/word_provider.dart';

class WordCreatePage extends ConsumerWidget {
  const WordCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(wordViewModelProvider);
    final wordController = TextEditingController();
    final meaningController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('英単語暗記アプリ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: wordController,
              decoration: const InputDecoration(labelText: '単語'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: meaningController,
              decoration: const InputDecoration(labelText: '意味'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final word = wordController.text;
              final meaning = meaningController.text;
              ref.read(wordViewModelProvider.notifier).addWord(word, meaning);
              wordController.clear();
              meaningController.clear();
            },
            child: const Text('単語を追加'),
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
