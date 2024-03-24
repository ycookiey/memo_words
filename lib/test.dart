import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';

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

class FlipCardExample extends StatelessWidget {
  FlipCardExample({super.key});
  final con1 = FlipCardController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlipCard(
          rotateSide: RotateSide.bottom,
          controller: con1,
          animationDuration: const Duration(milliseconds: 300),
          axis: FlipAxis.horizontal,
          frontWidget: const Card(
            color: Color(0xffcce3f3),
            elevation: 10,
            shadowColor: Colors.black,
            child: SizedBox(
              width: 275,
              height: 380,
              child: Center(child: Text('Test1')),
            ),
          ),
          backWidget: const Card(
            color: Color(0xffcce3f3),
            elevation: 10,
            shadowColor: Colors.black,
            child: SizedBox(
              width: 275,
              height: 380,
              child: Center(child: Text('Test2')),
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
      ],
    );
  }
}