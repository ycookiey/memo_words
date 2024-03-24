import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<List> wordData = [["Str1", "Str2"],["Str3", "Str4"],["Str3efw", "Str4"],["Str1", "Str2"],["Str1", "Str2"],["Str1", "Str2"],["Str1", "Str2"],["Str1", "Str2"],["Str1", "Str2"],["Str1", "Str2"],["Str1", "Str2"],["Str0", "Str2"],];

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
          ],
        ),
      ),
    );
  }
}

class ElevatedCardExample extends StatelessWidget {
  const ElevatedCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Card(
            color: Color(0xffcce3f3),
            elevation: 10,
            shadowColor: Colors.black,
            child: SizedBox(
              width: 275,
              height: 80,
              child: Center(child: Text('Card1')),
            ),
          ),
        ],
      ),
    );
  }
}

final countProvider = StateProvider((ref) {
  return 0;
});

class FlipCardExample extends ConsumerWidget {
  FlipCardExample({super.key});
  final con1 = FlipCardController();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cardNum = ref.watch(countProvider);
    return Column(
      children: <Widget>[
        FlipCard(
          rotateSide: RotateSide.bottom,
          controller: con1,
          animationDuration: const Duration(milliseconds: 300),
          axis: FlipAxis.horizontal,
          frontWidget: Card(
            color: const Color(0xffcce3f3),
            elevation: 10,
            shadowColor: Colors.black,
            child: InkWell(
              onTap: () {
                con1.flipcard();
              },
              child: SizedBox(
                width: 275,
                height: 380,
                child: Center(child: Text(wordData[cardNum][0])),
              ),
            ),
          ),
          backWidget: Card(
            color: const Color(0xffcce3f3),
            elevation: 10,
            shadowColor: Colors.black,
            child: InkWell(
              onTap: () {
                con1.flipcard();
              },
              child: SizedBox(
                width: 275,
                height: 380,
                child: Center(child: Text(wordData[cardNum][1])),
              ),
            ),
          ),
        ),
        const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: const Text('回転'),
            onPressed: () {
              con1.flipcard();
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: const Text('進む'),
            onPressed: () {
              if (cardNum < wordData.length-1) {
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