import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/provider/word_provider.dart';
import 'package:memo_words/widgets/word_input_field.dart';

class FlashCardCreatePage extends ConsumerStatefulWidget {
  const FlashCardCreatePage({Key? key}) : super(key: key);

  @override
  _FlashCardCreatePageState createState() => _FlashCardCreatePageState();
}

class _FlashCardCreatePageState extends ConsumerState<FlashCardCreatePage> {
  final flashcardNameController = TextEditingController();
  final _flashCardInputFormKey = GlobalKey<FormState>();
  final _wordInputFormKey = GlobalKey<FormState>();
  List<WordPair> wordPairs = [
    WordPair(),
    WordPair(),
  ];

  @override
  void dispose() {
    for (var pair in wordPairs) {
      pair.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しい単語帳を作成'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createFlashcard,
        child: const Icon(Icons.check),
      ),
      body: Form(
        key: _flashCardInputFormKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  controller: flashcardNameController,
                  decoration: const InputDecoration(labelText: '単語帳名'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '単語帳名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Form(key: _wordInputFormKey, child: _buildWordInputList()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _createNewWordPair,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordInputList() {
    return Column(
      children: wordPairs
          .map((wordPair) => WordInputField(
                wordController: wordPair.wordController,
                meaningController: wordPair.meaningController,
                wordFocusNode: wordPair.wordFocusNode,
                meaningFocusNode: wordPair.meaningFocusNode,
                onRemove: () => _removeWordPair(wordPair),
                onNextField: () => _focusNextField(wordPair),
              ))
          .toList(),
    );
  }

  void _focusNextField(WordPair currentPair) {
    int currentIndex = wordPairs.indexOf(currentPair);
    if (currentIndex == wordPairs.length - 1) {
      _createNewWordPair();
    } else {
      FocusScope.of(context)
          .requestFocus(wordPairs[currentIndex + 1].wordFocusNode);
    }
  }

  void _createNewWordPair() {
    if (_wordInputFormKey.currentState!.validate()) {
      setState(() {
        wordPairs.add(WordPair());
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(wordPairs.last.wordFocusNode);
      });
    } else {
      _focusFirstErrorField();
    }
  }

  void _focusFirstErrorField() {
    for (var wordPair in wordPairs) {
      if (wordPair.wordController.text.isEmpty) {
        FocusScope.of(context).requestFocus(wordPair.wordFocusNode);
        return;
      }
      if (wordPair.meaningController.text.isEmpty) {
        FocusScope.of(context).requestFocus(wordPair.meaningFocusNode);
        return;
      }
    }
  }

  void _removeWordPair(WordPair pair) {
    setState(() {
      wordPairs.remove(pair);
      if (wordPairs.isEmpty) {
        wordPairs.add(WordPair());
      }
    });
  }

  void _createFlashcard() async {
    if (_flashCardInputFormKey.currentState!.validate()) {
      final name = flashcardNameController.text;
      final validWordPairs = wordPairs
          .where((wp) =>
              wp.wordController.text.isNotEmpty &&
              wp.meaningController.text.isNotEmpty)
          .toList();

      try {
        final flashcard =
            await ref.read(wordViewModelProvider.notifier).addFlashcard(name);
        for (var wordPair in validWordPairs) {
          await ref.read(wordViewModelProvider.notifier).addWord(
                flashcard.id,
                wordPair.wordController.text,
                wordPair.meaningController.text,
              );
        }
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }
}

class WordPair {
  final TextEditingController wordController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final FocusNode wordFocusNode = FocusNode();
  final FocusNode meaningFocusNode = FocusNode();

  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    wordFocusNode.dispose();
    meaningFocusNode.dispose();
  }
}
