import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/provider/word_provider.dart';

class FlashCardEditPage extends ConsumerStatefulWidget {
  const FlashCardEditPage({Key? key}) : super(key: key);

  @override
  _FlashCardEditState createState() => _FlashCardEditState();
}

class _FlashCardEditState extends ConsumerState<FlashCardEditPage> {
  final flashcardNameController = TextEditingController();
  final _flashCardInputFormKey = GlobalKey<FormState>();
  final _wordInputFormKey = GlobalKey<FormState>();
  String? selectedFlashcardId;
  List<WordPair> wordPairs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedId = ref.read(selectedFlashcardIdProvider);
      if (selectedId != null) {
        setState(() {
          selectedFlashcardId = selectedId;
        });
        _updateFlashcardName();
        _loadWords();
      }
    });
  }

  @override
  void dispose() {
    flashcardNameController.dispose();
    for (var pair in wordPairs) {
      pair.dispose();
    }
    super.dispose();
  }

  void _updateFlashcardName() {
    if (selectedFlashcardId != null) {
      final flashcard = ref
          .read(wordViewModelProvider.notifier)
          .getFlashcardById(selectedFlashcardId!);
      if (flashcard != null) {
        flashcardNameController.text = flashcard.name;
      }
    }
  }

  void _loadWords() {
    if (selectedFlashcardId != null) {
      final words = ref
          .read(wordViewModelProvider.notifier)
          .getWordsForFlashcard(selectedFlashcardId!);
      setState(() {
        wordPairs = words
            .map((word) => WordPair(
                  wordController: TextEditingController(text: word.word),
                  meaningController: TextEditingController(text: word.meaning),
                  id: word.id,
                ))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語帳編集'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateFlashcard,
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
                if (selectedFlashcardId != null) ...[
                  Form(key: _wordInputFormKey, child: _buildWordInputList()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createNewWordPair,
                    child: const Icon(Icons.add),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordInputList() {
    return Column(
      children:
          wordPairs.map((wordPair) => _buildWordInputRow(wordPair)).toList(),
    );
  }

  Widget _buildWordInputRow(WordPair wordPair) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              focusNode: wordPair.wordFocusNode,
              textInputAction: TextInputAction.next,
              controller: wordPair.wordController,
              decoration: const InputDecoration(
                  labelText: '単語', labelStyle: TextStyle(fontSize: 12)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '単語を入力してください';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(wordPair.meaningFocusNode);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              focusNode: wordPair.meaningFocusNode,
              textInputAction: TextInputAction.next,
              controller: wordPair.meaningController,
              decoration: const InputDecoration(
                  labelText: '意味', labelStyle: TextStyle(fontSize: 12)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '意味を入力してください';
                }
                return null;
              },
              onFieldSubmitted: (_) => _focusNextField(wordPair),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => _removeWordPair(wordPair),
          ),
        ],
      ),
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
    });
    if (pair.id != null) {
      ref
          .read(wordViewModelProvider.notifier)
          .deleteWord(selectedFlashcardId!, pair.id!);
    }
  }

  void _updateFlashcard() async {
    if (_flashCardInputFormKey.currentState!.validate() &&
        _wordInputFormKey.currentState!.validate()) {
      final name = flashcardNameController.text;

      try {
        await ref
            .read(wordViewModelProvider.notifier)
            .updateFlashcard(selectedFlashcardId!, name);

        for (var wordPair in wordPairs) {
          if (wordPair.id != null) {
            await ref.read(wordViewModelProvider.notifier).updateWord(
                  selectedFlashcardId!,
                  wordPair.id!,
                  wordPair.wordController.text,
                  wordPair.meaningController.text,
                );
          } else {
            await ref.read(wordViewModelProvider.notifier).addWord(
                  selectedFlashcardId!,
                  wordPair.wordController.text,
                  wordPair.meaningController.text,
                );
          }
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
  final TextEditingController wordController;
  final TextEditingController meaningController;
  final FocusNode wordFocusNode = FocusNode();
  final FocusNode meaningFocusNode = FocusNode();
  final String? id;

  WordPair({
    TextEditingController? wordController,
    TextEditingController? meaningController,
    this.id,
  })  : wordController = wordController ?? TextEditingController(),
        meaningController = meaningController ?? TextEditingController();

  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    wordFocusNode.dispose();
    meaningFocusNode.dispose();
  }
}
