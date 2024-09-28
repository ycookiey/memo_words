import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/main.dart';
import 'package:memo_words/provider/word_provider.dart';
import 'package:memo_words/view/word_card_page.dart';

class KnownTestProgress extends ConsumerWidget {
  const KnownTestProgress({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cardNum = ref.watch(cardNumProvider);
    final knownWords = ref.watch(knownSelectedFlashcardWordsProvider);
    final finishedWordCount = ref.watch(finishedWordCountProvider);
    double progressValue = 0.0;
    if (knownWords.isNotEmpty) {
      progressValue = finishedWordCount / knownWords.length;
    }

    return Column(
      children: knownWords.isEmpty
          ? [const SizedBox()]
          : [
              Text('${cardNum + 1} / ${knownWords.length}'),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: knownWords.isEmpty ? 0 : progressValue,
                backgroundColor: const Color(0xffcec5f0),
              ),
            ],
    );
  }
}

class KnownTestFlipCards extends ConsumerStatefulWidget {
  KnownTestFlipCards({super.key});

  @override
  ConsumerState<KnownTestFlipCards> createState() => _KnownTestFlipCardsState();
}

class _KnownTestFlipCardsState extends ConsumerState<KnownTestFlipCards> {
  final flipController = FlipCardController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var knownWords = ref.read(knownSelectedFlashcardWordsProvider);
      if (knownWords.isNotEmpty) {
        var shuffledList = NumberShuffle().getShuffleList(knownWords.length);
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
    final knownWords = ref.watch(knownSelectedFlashcardWordsProvider);

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

    if (knownWords.isEmpty) {
      return const Text('単語がありません');
    }

    int currentIndex = isShuffled ? shuffledCardNum[cardNum] : cardNum;
    Widget frontWidget = buildCard(knownWords[currentIndex].word);
    Widget backWidget = buildCard(knownWords[currentIndex].meaning);

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
