import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_words/model/firestore/flashcard_model.dart';
import 'package:memo_words/model/firestore/word_model.dart';
import 'package:memo_words/repository/word_repository.dart';

class WordViewModel extends StateNotifier<List<Flashcard>> {
  final WordRepository _wordRepository;

  WordViewModel(this._wordRepository) : super([]) {
    initialize();
  }

  Future<void> initialize() async {
    var flashcards = await _wordRepository.getFlashcards();
    state = flashcards;
  }

  Future<void> addFlashcard(String name) async {
    Flashcard newFlashcard = await _wordRepository.addFlashcard(name);
    state = [...state, newFlashcard];
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    await _wordRepository.deleteFlashcard(flashcardId);
    state = state.where((flashcard) => flashcard.id != flashcardId).toList();
  }

  Future<void> updateFlashcard(String flashcardId, String newName) async {
    await _wordRepository.updateFlashcard(flashcardId, newName);
    state = state.map((flashcard) {
      if (flashcard.id == flashcardId) {
        return flashcard.copyWith(name: newName);
      }
      return flashcard;
    }).toList();
  }

  Future<void> addWord(
      String flashcardId, String englishWord, String japaneseMeaning) async {
    Word newWord = await _wordRepository.addWord(
        flashcardId, englishWord, japaneseMeaning);
    state = state.map((flashcard) {
      if (flashcard.id == flashcardId) {
        return flashcard.copyWith(words: [...flashcard.words, newWord]);
      }
      return flashcard;
    }).toList();
  }

  Future<void> deleteWord(String flashcardId, String wordId) async {
    await _wordRepository.deleteWord(flashcardId, wordId);
    state = state.map((flashcard) {
      if (flashcard.id == flashcardId) {
        return flashcard.copyWith(
          words: flashcard.words.where((word) => word.id != wordId).toList(),
        );
      }
      return flashcard;
    }).toList();
  }

  Future<void> updateWord(String flashcardId, String wordId, String newWord,
      String newMeaning) async {
    await _wordRepository.updateWord(flashcardId, wordId, newWord, newMeaning);
    state = state.map((flashcard) {
      if (flashcard.id == flashcardId) {
        return flashcard.copyWith(
          words: flashcard.words.map((word) {
            if (word.id == wordId) {
              return word.copyWith(word: newWord, meaning: newMeaning);
            }
            return word;
          }).toList(),
        );
      }
      return flashcard;
    }).toList();
  }

  Future<void> addMistakenDate(String flashcardId, String wordId) async {
    await _wordRepository.addMistakenDate(flashcardId, wordId);
    state = state.map((flashcard) {
      if (flashcard.id == flashcardId) {
        return flashcard.copyWith(
          words: flashcard.words.map((word) {
            if (word.id == wordId) {
              return word.copyWith(
                mistakenDates: [...word.mistakenDates, DateTime.now()],
              );
            }
            return word;
          }).toList(),
        );
      }
      return flashcard;
    }).toList();
  }

  Flashcard? getFlashcardById(String flashcardId) {
    return state.firstWhere((flashcard) => flashcard.id == flashcardId);
  }

  List<Word> getWordsForFlashcard(String flashcardId) {
    Flashcard? flashcard = getFlashcardById(flashcardId);
    return flashcard?.words ?? [];
  }
}
