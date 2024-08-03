import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/model/firestore/flashcard_model.dart';
import 'package:memo_words/model/firestore/word_model.dart';
import 'package:memo_words/repository/word_repository.dart';
import 'package:memo_words/view_model/word_view_model.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository();
});

final wordViewModelProvider =
    StateNotifierProvider<WordViewModel, List<Flashcard>>((ref) {
  final repository = ref.watch(wordRepositoryProvider);
  return WordViewModel(repository);
});

final selectedFlashcardIdProvider = StateProvider<String?>((ref) => null);

final selectedFlashcardWordsProvider = Provider<List<Word>>((ref) {
  final selectedFlashcardId = ref.watch(selectedFlashcardIdProvider);
  final flashcards = ref.watch(wordViewModelProvider);

  if (selectedFlashcardId == null) {
    return [];
  }

  final selectedFlashcard = flashcards.firstWhere(
    (flashcard) => flashcard.id == selectedFlashcardId,
    orElse: () => Flashcard(
        id: '',
        name: '',
        words: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()),
  );

  return selectedFlashcard.words;
});
