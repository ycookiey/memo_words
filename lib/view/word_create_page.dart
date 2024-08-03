import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/model/firestore/flashcard_model.dart';
import 'package:memo_words/model/firestore/word_model.dart';
import 'package:memo_words/provider/word_provider.dart';

class WordCreatePage extends ConsumerStatefulWidget {
  const WordCreatePage({Key? key}) : super(key: key);

  @override
  _WordCreatePageState createState() => _WordCreatePageState();
}

class _WordCreatePageState extends ConsumerState<WordCreatePage> {
  final wordController = TextEditingController();
  final meaningController = TextEditingController();
  final flashcardNameController = TextEditingController();
  String? selectedFlashcardId;

  @override
  Widget build(BuildContext context) {
    final flashcards = ref.watch(wordViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('単語帳管理'),
      ),
      body: Column(
        children: [
          _buildFlashcardSelector(flashcards),
          _buildAddFlashcardSection(),
          if (selectedFlashcardId != null) ...[
            _buildAddWordSection(),
            _buildWordList(selectedFlashcardId!),
          ],
        ],
      ),
    );
  }

  Widget _buildFlashcardSelector(List<Flashcard> flashcards) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: selectedFlashcardId,
        hint: const Text('単語帳を選択'),
        isExpanded: true,
        items: flashcards.map((flashcard) {
          return DropdownMenuItem<String>(
            value: flashcard.id,
            child: Text(flashcard.name),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedFlashcardId = newValue;
          });
        },
      ),
    );
  }

  Widget _buildAddFlashcardSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: flashcardNameController,
              decoration: const InputDecoration(labelText: '新しい単語帳名'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = flashcardNameController.text;
              if (name.isNotEmpty) {
                ref.read(wordViewModelProvider.notifier).addFlashcard(name);
                flashcardNameController.clear();
              }
            },
            child: const Text('単語帳を追加'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddWordSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: wordController,
            decoration: const InputDecoration(labelText: '単語'),
          ),
          TextField(
            controller: meaningController,
            decoration: const InputDecoration(labelText: '意味'),
          ),
          ElevatedButton(
            onPressed: () {
              final word = wordController.text;
              final meaning = meaningController.text;
              if (word.isNotEmpty &&
                  meaning.isNotEmpty &&
                  selectedFlashcardId != null) {
                ref
                    .read(wordViewModelProvider.notifier)
                    .addWord(selectedFlashcardId!, word, meaning);
                wordController.clear();
                meaningController.clear();
              }
            },
            child: const Text('単語を追加'),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList(String flashcardId) {
    final words = ref
        .watch(wordViewModelProvider.notifier)
        .getWordsForFlashcard(flashcardId);

    return Expanded(
      child: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          final word = words[index];
          return ListTile(
            title: Text(word.word),
            subtitle: Text(word.meaning),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(flashcardId, word),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref
                        .read(wordViewModelProvider.notifier)
                        .deleteWord(flashcardId, word.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(String flashcardId, Word word) {
    final editWordController = TextEditingController(text: word.word);
    final editMeaningController = TextEditingController(text: word.meaning);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('単語を編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editWordController,
                decoration: const InputDecoration(labelText: '単語'),
              ),
              TextField(
                controller: editMeaningController,
                decoration: const InputDecoration(labelText: '意味'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                ref.read(wordViewModelProvider.notifier).updateWord(
                      flashcardId,
                      word.id,
                      editWordController.text,
                      editMeaningController.text,
                    );
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}
