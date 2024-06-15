import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/provider/word_provider.dart';

class WordCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlipCardExample(),
            const Others(),
          ],
        ),
      ),
    );
  }
}

final countProvider = StateProvider((ref) {
  return 0;
});

class FlipCardExample extends ConsumerWidget {
  FlipCardExample({super.key});
  final flipController = FlipCardController();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cardNum = ref.watch(countProvider);
    final words = ref.watch(wordViewModelProvider);
    return Column(
      children: <Widget>[
        FlipCard(
          rotateSide: RotateSide.bottom,
          controller: flipController,
          animationDuration: const Duration(milliseconds: 300),
          axis: FlipAxis.horizontal,
          frontWidget: Card(
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
                child: Center(child: Text(words[cardNum].word)),
              ),
            ),
          ),
          backWidget: Card(
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
                child: Center(child: Text(words[cardNum].meaning)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Others extends ConsumerWidget {
  const Others({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cardNum = ref.watch(countProvider);
    final words = ref.watch(wordViewModelProvider);
    return Column(
      children: [
        ElevatedButton(
          child: const Text('〇'),
          onPressed: () {
            if (cardNum < words.length-1) {
              ref.read(countProvider.notifier).state++;
            } else {
              ref.read(countProvider.notifier).state = 0;
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          child: const Text('×'),
          onPressed: () {
            if (cardNum < words.length-1) {
              ref.read(countProvider.notifier).state++;
            } else {
              ref.read(countProvider.notifier).state = 0;
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
          child: const Text('戻る'),
          onPressed: () {
            if (cardNum > 0) {
              ref.read(countProvider.notifier).state--;
            }
          },
        ),
      ],
    );
  }
}
