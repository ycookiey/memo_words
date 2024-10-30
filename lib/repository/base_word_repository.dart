import 'package:memo_words/model/firestore/flashcard_model.dart';
import 'package:memo_words/model/firestore/word_model.dart';

abstract class BaseWordRepository {
  Future<List<Flashcard>> getFlashcards();
  Future<Flashcard> addFlashcard(String name);
  Future<void> updateFlashcard(String flashcardId, String newName);
  Future<void> deleteFlashcard(String flashcardId);
  Future<Word> addWord(
      String flashcardId, String englishWord, String japaneseMeaning);
  Future<void> updateWord(
      String flashcardId, String wordId, String newWord, String newMeaning);
  Future<void> deleteWord(String flashcardId, String wordId);
  Future<List<Word>> getKnownWords(String flashcardId);
  Future<List<Word>> getUnknownWords(String flashcardId);
  Future<void> addCorrectAt(String flashcardId, String wordId);
  Future<void> addMistookAt(String flashcardId, String wordId);
  Future<void> toggleInProgress(String flashcardId, String wordId);
  Future<void> resetInProgress(String? flashcardId);
}
