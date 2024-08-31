import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/main.dart';
import 'package:memo_words/provider/word_provider.dart';
import 'package:memo_words/view/flash_card_create_page.dart';
import 'package:memo_words/view/word_card_page.dart';
import 'package:memo_words/view/flash_card_edit_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage(this.isShuffled, {super.key});
  final bool isShuffled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcards = ref.watch(wordViewModelProvider);
    final isShuffled = ref.watch(shuffledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('単語帳アプリ'),
      ),
      body: Column(
        children: [
          Expanded(
            child: flashcards.isEmpty
                ? const Center(child: Text('単語帳がありません。新しい単語帳を作成してください。'))
                : ListView.builder(
                    itemCount: flashcards.length,
                    itemBuilder: (context, index) {
                      final flashcard = flashcards[index];
                      return ListTile(
                        title: Text(flashcard.name),
                        subtitle: Text('${flashcard.words.length} 個の単語'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                ref
                                    .read(selectedFlashcardIdProvider.notifier)
                                    .state = flashcard.id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FlashCardEditPage()),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () {
                                ref
                                    .read(selectedFlashcardIdProvider.notifier)
                                    .state = flashcard.id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordCardPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  child: const Text("新しい単語帳を作成"),
                  onPressed: () {
                    ref.read(selectedFlashcardIdProvider.notifier).state = null;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FlashCardCreatePage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('単語シャッフル'),
                  value: isShuffled,
                  onChanged: (value) {
                    ref.read(shuffledProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
