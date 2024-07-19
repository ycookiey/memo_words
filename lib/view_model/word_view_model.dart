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

  Future<void> addWord(
      String listName, String englishWord, String japaneseMeaning) async {
    Word newWord =
        await _wordRepository.addWord(listName, englishWord, japaneseMeaning);
    state = [...state, newWord];
  }

  Future<void> getWords() async {
    List<Word> words = await _wordRepository.getWords();
    state = words;
  }

  Future<void> deleteWord(String id) async {
    await _wordRepository.deleteWord(id);
    state = state.where((element) => element.id != id).toList();
  }

  Future<void> updateWord(String id, String word, String meaning) async {
    await _wordRepository.updateWord(id, word, meaning);
    state = state
        .map((element) => element.id == id
            ? element.copyWith(word: word, meaning: meaning)
            : element)
        .toList();
  }

  Future<void> addMistakenDate(String id) async {
    await _wordRepository.addMistakenDate(id);
    state = state
        .map((element) => element.id == id
            ? element.copyWith(
                mistakenDates: [...element.mistakenDates, DateTime.now()])
            : element)
        .toList();
  }
}
