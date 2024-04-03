import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/model/firestore/firestore_model.dart';
import 'package:memo_words/repository/word_repository.dart';

class WordViewModel extends StateNotifier<List<Word>> {
  final WordRepository _wordRepository;

  WordViewModel(this._wordRepository) : super([]) {
    initialize();
  }

  Future<void> initialize() async {
    var words = await _wordRepository.getWords();
    state = words;
  }

  Future<void> addWord(String word, String meaning) async {
    final newWord = await _wordRepository.addWord(word, meaning);
    if (newWord != null) {
      state = [...state, newWord];
    }
  }

  Future<void> getWords() async {
    List<Word> words = await _wordRepository.getWords();
    state = words;
  }
}
