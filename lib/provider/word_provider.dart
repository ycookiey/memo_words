import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/repository/word_repository.dart';
import 'package:memo_words/view_model/word_view_model.dart';

final wordViewModelProvider = Provider<WordViewModel>((ref) {
  return WordViewModel(WordRepository());
});
