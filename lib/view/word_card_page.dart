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
        actions: [
          IconButton(onPressed: () => {
            showModalBottomSheet<void>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              enableDrag: true,
              barrierColor: Colors.black.withOpacity(0.5),
              builder: (context) {
                return const _BottomSheet();
              }),
          }, icon: const Icon(Icons.settings)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const Progress(),
            FlipCardExample(),
            const Others(),
          ],
        ),
      ),
    );
  }
}

class _BottomSheet extends ConsumerWidget {
  const _BottomSheet({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isReverse = ref.watch(reverseProvider);
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
          const SizedBox(
            height: 10,
          ),
          const Row(
            children: [
              Text(
                'オプション',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          SwitchListTile(
            title: const Text('反転'),
            value: isReverse,
            onChanged: (value) {
              ref.read(reverseProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }
}

final countProvider = StateProvider((ref) {
  return 0;
});

final reverseProvider = StateProvider((ref) {
  return false;
});

class FlipCardExample extends ConsumerWidget {
  FlipCardExample({super.key});
  final flipController = FlipCardController();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isReverse = ref.watch(reverseProvider);
    var cardNum = ref.watch(countProvider);
    final words = ref.watch(wordViewModelProvider);
    Widget frontWidget = Card(
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
          child: words.isEmpty ? const SizedBox() : Center(child: Text(words[cardNum].word)),
        ),
      ),
    );

    Widget backWidget = Card(
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
          child: words.isEmpty ? const SizedBox() : Center(child: Text(words[cardNum].meaning)),
        ),
      ),
    );

    return Column(
      children: <Widget>[
        words.isEmpty
          ? const Text('単語がありません')
          : FlipCard(
          rotateSide: RotateSide.bottom,
          controller: flipController,
          animationDuration: const Duration(milliseconds: 300),
          axis: FlipAxis.horizontal,
          frontWidget: isReverse ? backWidget : frontWidget,
          backWidget: isReverse ? frontWidget : backWidget,
        ),
      ],
    );
  }
}

class Progress extends ConsumerWidget {
  const Progress({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cardNum = ref.watch(countProvider);
    final words = ref.watch(wordViewModelProvider);
    return Column(
      children: words.isEmpty ? [const SizedBox()] 
        : [
          Text('${cardNum + 1} / ${words.length}'),
          const SizedBox(
            height: 5,
          ),
          LinearProgressIndicator(
            value: cardNum / words.length,
            backgroundColor: const Color(0xffcec5f0),
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
      children: words.isEmpty ? [const SizedBox()]
        : [
          ElevatedButton(
            child: const Text('〇'),
            onPressed: () {
              if (cardNum < words.length-1) {
                ref.read(countProvider.notifier).state++;
              } else {
                ref.read(countProvider.notifier).state = 0;
                ref.read(reverseProvider.notifier).state = false;
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
                ref.read(reverseProvider.notifier).state = false;
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
