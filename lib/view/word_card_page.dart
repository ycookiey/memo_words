import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/main.dart';
import 'package:memo_words/provider/word_provider.dart';
import 'package:memo_words/view/all_words_test.dart';
import 'package:memo_words/view/known_words_test.dart';
import 'package:memo_words/view/unknown_words_test.dart';

final cardNumProvider = StateProvider((ref) => 0);
final reverseProvider = StateProvider((ref) => false);
final shuffledListProvider = StateProvider<List<int>>((ref) => []);

class WordCardPage extends ConsumerWidget {
  const WordCardPage(this.testMode, {super.key});
  final String testMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFlashcardId = ref.watch(selectedFlashcardIdProvider);
    if (selectedFlashcardId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('単語カード')),
        body: const Center(child: Text('単語帳が選択されていません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: testElements(testMode),
        ),
      ),
    );
  }

  List<Widget> testElements(String testMode) {
    if (testMode == 'allWordsTest') {
      return [
        const Progress(),
        FlipCards(),
        const AllTestButtons(),
      ];
    } else if (testMode == 'knownWordsTest') {
      return [
        const KnownTestProgress(),
        KnownTestFlipCards(),
        const KnownTestButtons(),
      ];
    } else if (testMode == 'unknownWordsTest') {
      return [
        const UnknownTestProgress(),
        UnknownTestFlipCards(),
        const UnknownTestButtons(),
      ];
    } else {
      return [];
    }
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return const _BottomSheet();
      },
    );
  }
}

class _BottomSheet extends ConsumerWidget {
  const _BottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isReverse = ref.watch(reverseProvider);
    var isShuffled = ref.watch(shuffledProvider);
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      margin: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                'オプション',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('反転'),
            value: isReverse,
            onChanged: (value) {
              ref.read(reverseProvider.notifier).state = value;
            },
          ),
          SwitchListTile(
            title: const Text('単語シャッフル'),
            value: isShuffled,
            onChanged: (value) {
              ref.read(shuffledProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }
}

class NumberShuffle {
  List<int> getShuffleList(int inputNum) {
    List<int> list = List.generate(inputNum, (index) => index);
    list.shuffle();
    return list;
  }
}

class WaitableElevatedButton extends StatefulWidget {

  WaitableElevatedButton({
    required this.onPressed,
    required this.child,
    super.key,
  });
  @override
  createState() => _WaitableElevatedButtonState();

  final AsyncCallback onPressed;
  final Widget child;
}

class _WaitableElevatedButtonState extends State<WaitableElevatedButton> {
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _waiting 
        ? null 
        : () async {
          setState(() => _waiting = true);
          await widget.onPressed();
          Future.delayed(const Duration(milliseconds: 50), () {
            setState(() => _waiting = false);
          });
        },
      child: widget.child,
    );
  }
}

class Buttons extends ConsumerWidget {
  final List words;
  final int wordsListLength;
  const Buttons(this.words, this.wordsListLength, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cardNum = ref.watch(cardNumProvider);
    final selectedFlashcardId = ref.watch(selectedFlashcardIdProvider);

    Future<void> nextWord() async {
      if (selectedFlashcardId != null) {
        try {
          await ref
              .read(wordViewModelProvider.notifier)
              .toggleInProgress(
                selectedFlashcardId,
                words[cardNum].id,
              );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      }
      if (cardNum < wordsListLength - 1) {
        ref.watch(cardNumProvider.notifier).update((state) => state + 1);
      } else if (cardNum >= wordsListLength - 1) {
        _showCompletionDialog(context, ref);
      }
    }

    Future<void> correctNextWord() async {
      if (selectedFlashcardId != null) {
        try {
          await ref
              .read(wordViewModelProvider.notifier)
              .addCorrectAt(
                selectedFlashcardId,
                words[cardNum].id,
              );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      }
      nextWord();
    }

    Future<void> mistakeNextWord() async {
      if (selectedFlashcardId != null) {
        try {
          await ref
              .read(wordViewModelProvider.notifier)
              .addMistookAt(
                selectedFlashcardId,
                words[cardNum].id,
              );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('エラーが発生しました: $e')),
          );
        }
      }
      nextWord();
    }

    Future<void> previousWord() async {
      if (cardNum > 0) {
        ref.read(cardNumProvider.notifier).state--;
      } else {
        ref.read(cardNumProvider.notifier).state = 0;
      }
      if (selectedFlashcardId != null) {
        await ref.read(wordViewModelProvider.notifier).toggleInProgress(
              selectedFlashcardId,
              words[cardNum].id,
            );
      } else {
        return;
      }
    }

    return Column(
      children: words.isEmpty
          ? [const SizedBox()]
          : [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WaitableElevatedButton(
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await mistakeNextWord();
                    },
                  ),
                  const SizedBox(width: 10),
                  WaitableElevatedButton(
                    child: const Icon(
                      Icons.circle_outlined,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      await correctNextWord();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              WaitableElevatedButton(
                onPressed: () async {
                  if (cardNum != 0) {
                    await previousWord();
                  }
                },
                child: Icon(Icons.undo),
              ),
            ],
    );
  }

  void _showCompletionDialog(BuildContext context, WidgetRef ref) {
    final selectedFlashcardId = ref.watch(selectedFlashcardIdProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('テスト完了'),
        content: const Text('すべての単語をテストしました。'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              await ref
                  .read(wordViewModelProvider.notifier)
                  .resetInProgress(selectedFlashcardId);
              ref.read(cardNumProvider.notifier).state = 0;
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class AllTestButtons extends ConsumerWidget {
  const AllTestButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allWords = ref.watch(selectedFlashcardWordsProvider);
    final wordsListLength = allWords.length;
    return Buttons(allWords, wordsListLength);
  }
}

class KnownTestButtons extends ConsumerWidget {
  const KnownTestButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final knownWords = ref.watch(knownSelectedFlashcardWordsProvider);
    final wordsListLength = knownWords.length;
    return Buttons(knownWords, wordsListLength);
  }
}

class UnknownTestButtons extends ConsumerWidget {
  const UnknownTestButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unknownWords = ref.watch(unknownSelectedFlashcardWordsProvider);
    final wordsListLength = unknownWords.length;
    return Buttons(unknownWords, wordsListLength);
  }
}
