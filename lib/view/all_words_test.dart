import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/main.dart';
import 'package:memo_words/provider/word_provider.dart';
import 'package:memo_words/view/word_card_page.dart';

class Progress extends ConsumerWidget {
  const Progress({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cardNum = ref.watch(cardNumProvider);
    final words = ref.watch(selectedFlashcardWordsProvider);
    final finishedWordCount = ref.watch(finishedWordCountProvider);
    double progressValue = 0.0;
    if (words.isNotEmpty) {
      progressValue = finishedWordCount / words.length;
    }

    return Column(
      children: words.isEmpty
          ? [const SizedBox()]
          : [
              Text('${cardNum + 1} / ${words.length}'),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: words.isEmpty ? 0 : progressValue,
                backgroundColor: const Color(0xffcec5f0),
              ),
            ],
    );
  }
}

class FlipCards extends ConsumerStatefulWidget {
  FlipCards({super.key});

  @override
  ConsumerState<FlipCards> createState() => _FlipCardsState();
}

class _FlipCardsState extends ConsumerState<FlipCards> {
  final flipController = FlipCardController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var words = ref.read(selectedFlashcardWordsProvider);
      if (words.isNotEmpty) {
        var shuffledList = NumberShuffle().getShuffleList(words.length);
        ref.read(shuffledListProvider.notifier).state = shuffledList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var isReverse = ref.watch(reverseProvider);
    var cardNum = ref.watch(cardNumProvider);
    var isShuffled = ref.watch(shuffledProvider);
    var shuffledCardNum = ref.watch(shuffledListProvider);
    final words = ref.watch(selectedFlashcardWordsProvider);

    Widget buildCard(String content) {
      return Card(
        color: const Color(0xffcce3f3),
        elevation: 10,
        shadowColor: Colors.black,
        child: InkWell(
          onTap: () {
            flipController.flipcard();
          },
          child: SizedBox(
            width: 275,
            height: 380,
            child: Center(child: Text(content)),
          ),
        ),
      );
    }

    if (words.isEmpty) {
      return const Text('単語がありません');
    }

    int currentIndex = isShuffled ? shuffledCardNum[cardNum] : cardNum;
    Widget frontWidget = buildCard(words[currentIndex].word);
    Widget backWidget = buildCard(words[currentIndex].meaning);

    return FlipCard(
      rotateSide: RotateSide.bottom,
      controller: flipController,
      animationDuration: const Duration(milliseconds: 300),
      axis: FlipAxis.horizontal,
      frontWidget: isReverse ? backWidget : frontWidget,
      backWidget: isReverse ? frontWidget : backWidget,
    );
  }
}
