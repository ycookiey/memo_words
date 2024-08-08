import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/model/firestore/word_model.dart';
import 'package:memo_words/provider/word_provider.dart';

class FlashCardCreatePage extends ConsumerStatefulWidget {
  const FlashCardCreatePage({Key? key}) : super(key: key);

  @override
  _FlashCardCreatePageState createState() => _FlashCardCreatePageState();
}

class _FlashCardCreatePageState extends ConsumerState<FlashCardCreatePage> {
  final flashcardNameController = TextEditingController();
  final wordController = TextEditingController();
  final meaningController = TextEditingController();
  List<Word> words = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しい単語帳を作成'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: flashcardNameController,
                decoration: const InputDecoration(labelText: '単語帳名'),
              ),
              const SizedBox(height: 16),
              _buildAddWordSection(),
              const SizedBox(height: 16),
              _buildWordList(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createFlashcard,
                child: const Text('単語帳を作成'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddWordSection() {
    return Column(
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
          onPressed: _addWord,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildWordList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return ListTile(
          title: Text(word.word),
          subtitle: Text(word.meaning),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeWord(index),
          ),
        );
      },
    );
  }

  void _addWord() {
    final word = wordController.text;
    final meaning = meaningController.text;
    if (word.isNotEmpty && meaning.isNotEmpty) {
      setState(() {
        words.add(Word(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          word: word,
          meaning: meaning,
        ));
      });
      wordController.clear();
      meaningController.clear();
    }
  }

  void _removeWord(int index) {
    setState(() {
      words.removeAt(index);
    });
  }

  void _createFlashcard() async {
    final name = flashcardNameController.text;
    if (name.isNotEmpty && words.isNotEmpty) {
      try {
        final flashcard =
            await ref.read(wordViewModelProvider.notifier).addFlashcard(name);
        for (var word in words) {
          await ref
              .read(wordViewModelProvider.notifier)
              .addWord(flashcard.id, word.word, word.meaning);
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('単語帳名と少なくとも1つの単語を入力してください')),
      );
    }
  }
}
