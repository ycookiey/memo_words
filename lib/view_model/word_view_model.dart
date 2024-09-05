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

  Future<Flashcard> addFlashcard(String name) async {
    Flashcard newFlashcard = await _wordRepository.addFlashcard(name);
    state = [...state, newFlashcard];
    return newFlashcard;
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

    Future<List<Word>> getKnownWords(String flashcardId) async {
    try {
      return await _wordRepository.getKnownWords(flashcardId);
    } catch (e) {
      print('Error in getKnownWords: $e');
      rethrow;
    }
  }

  Future<List<Word>> getUnknownWords(String flashcardId) async {
    try {
      return await _wordRepository.getUnknownWords(flashcardId);
    } catch (e) {
      print('Error in getUnknownWords: $e');
      rethrow;
    }
  }

  Future<void> addCorrectAt(String flashcardId, String wordId) async {
    try {
      DateTime now = DateTime.now().toUtc();
      await _wordRepository.addCorrectAt(flashcardId, wordId);
      state = state.map((flashcard) {
        if (flashcard.id == flashcardId) {
          return flashcard.copyWith(
            words: flashcard.words.map((word) {
              if (word.id == wordId) {
                return word.copyWith(
                  correctAt: [...word.correctAt, now],
                );
              }
              return word;
            }).toList(),
          );
        }
        return flashcard;
      }).toList();
    } catch (e) {
      print('Error in addCorrectAt: $e');
      rethrow;
    }
  }

  Future<void> addMistookAt(String flashcardId, String wordId) async {
    try {
      DateTime now = DateTime.now().toUtc();
      await _wordRepository.addMistookAt(flashcardId, wordId);
      state = state.map((flashcard) {
        if (flashcard.id == flashcardId) {
          return flashcard.copyWith(
            words: flashcard.words.map((word) {
              if (word.id == wordId) {
                return word.copyWith(
                  mistookAt: [...word.mistookAt, now],
                );
              }
              return word;
            }).toList(),
          );
        }
        return flashcard;
      }).toList();
    } catch (e) {
      print('Error in addMistookAt: $e');
      rethrow;
    }
  }

  Future<void> toggleInProgress(String flashcardId, String wordId) async {
    try {
      await _wordRepository.toggleInProgress(flashcardId, wordId);
      state = state.map((flashcard) {
        if (flashcard.id == flashcardId) {
          return flashcard.copyWith(
            words: flashcard.words.map((word) {
              if (word.id == wordId) {
                return word.copyWith(inProgress: !word.inProgress);
              }
              return word;
            }).toList(),
          );
        }
        return flashcard;
      }).toList();
    } catch (e) {
      print('Error in toggleInProgress: $e');
      rethrow;
    }
  }

  Future<void> resetInProgress(String? flashcardId) async {
    try {
      await _wordRepository.resetInProgress(flashcardId);
      state = state.map((flashcard) {
        if (flashcard.id == flashcardId) {
          return flashcard.copyWith(
            words: flashcard.words.map((word) {
              return word.copyWith(inProgress: true);
            }).toList(),
          );
        }
        return flashcard;
      }).toList();
    } catch (e) {
      print('Error in resetInProgress: $e');
      rethrow;
    }
  }

  Flashcard? getFlashcardById(String flashcardId) {
    return state.firstWhere((flashcard) => flashcard.id == flashcardId);
  }

  List<Word> getWordsForFlashcard(String flashcardId) {
    Flashcard? flashcard = getFlashcardById(flashcardId);
    return flashcard?.words ?? [];
  }
}
