import 'package:memo_words/model/firestore/firestore_model.dart';
import 'package:memo_words/repository/word_repository.dart';

class WordViewModel {
  final WordRepository _wordRepository;

  WordViewModel(this._wordRepository);

  Future<Word?> addWord(String word, String meaning) async {
    return _wordRepository.addWord(word, meaning);
  }

  Future<List<Word>> getWords() async {
    return _wordRepository.getWords();
  }
}
