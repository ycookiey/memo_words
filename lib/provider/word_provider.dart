import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/model/firestore/flashcard_model.dart';
import 'package:memo_words/model/firestore/usage_stats_model.dart';
import 'package:memo_words/model/firestore/word_model.dart';
import 'package:memo_words/repository/base_word_repository.dart';
import 'package:memo_words/repository/tracked_word_repository.dart';
import 'package:memo_words/repository/usage_stats_repository.dart';
import 'package:memo_words/repository/word_repository.dart';
import 'package:memo_words/view_model/word_view_model.dart';

final wordRepositoryProvider = Provider<BaseWordRepository>((ref) {
  // 戻り値の型を変更
  return WordRepository();
});

final usageStatsRepositoryProvider = Provider<UsageStatsRepository>((ref) {
  return UsageStatsRepository();
});

final trackedWordRepositoryProvider = Provider<BaseWordRepository>((ref) {
  // 戻り値の型を変更
  return TrackedWordRepository(
    ref.read(wordRepositoryProvider) as WordRepository,
    ref.read(usageStatsRepositoryProvider),
  );
});

final wordViewModelProvider =
    StateNotifierProvider<WordViewModel, List<Flashcard>>((ref) {
  final repository = ref.watch(trackedWordRepositoryProvider);
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

final finishedWordCountProvider = Provider<int>((ref) {
  final words = ref.watch(selectedFlashcardWordsProvider);
  return words.where((word) => word.inProgress == false).length;
});
