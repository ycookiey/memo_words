import 'package:memo_words/model/firestore/flashcard_model.dart';
import 'package:memo_words/model/firestore/usage_stats_model.dart';
import 'package:memo_words/model/firestore/word_model.dart';
import 'package:memo_words/repository/base_word_repository.dart';
import 'package:memo_words/repository/usage_stats_repository.dart';
import 'package:memo_words/repository/word_repository.dart';

class TrackedWordRepository implements BaseWordRepository {
  final WordRepository _wordRepository;
  final UsageStatsRepository _usageStatsRepository;

  TrackedWordRepository(this._wordRepository, this._usageStatsRepository);

  void _printUsage(String operationName, int readCount, int writeCount) {
    print('🔥 Firebase Usage - $operationName:');
    print('  📖 Reads: $readCount');
    print('  ✍️ Writes: $writeCount');
    print(
        '  💰 Estimated cost: \$${((readCount * 0.036 + writeCount * 0.108) / 100000).toStringAsFixed(6)}');
    print('--------------------------------------------------');
  }

  @override
  Future<List<Flashcard>> getFlashcards() async {
    final result = await _wordRepository.getFlashcards();
    const int reads = 2;
    const int writes = 0;

    _printUsage('getFlashcards', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'getFlashcards',
      readCount: reads,
      writeCount: writes,
    );
    return result;
  }

  @override
  Future<Flashcard> addFlashcard(String name) async {
    final result = await _wordRepository.addFlashcard(name);
    const int reads = 1;
    const int writes = 1;

    _printUsage('addFlashcard', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'addFlashcard',
      readCount: reads,
      writeCount: writes,
    );
    return result;
  }

  @override
  Future<void> updateFlashcard(String flashcardId, String newName) async {
    await _wordRepository.updateFlashcard(flashcardId, newName);
    const int reads = 0;
    const int writes = 1;

    _printUsage('updateFlashcard', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'updateFlashcard',
      readCount: reads,
      writeCount: writes,
    );
  }

  @override
  Future<void> deleteFlashcard(String flashcardId) async {
    await _wordRepository.deleteFlashcard(flashcardId);
    const int reads = 0;
    const int writes = 1;

    _printUsage('deleteFlashcard', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'deleteFlashcard',
      readCount: reads,
      writeCount: writes,
    );
  }

  @override
  Future<Word> addWord(
      String flashcardId, String englishWord, String japaneseMeaning) async {
    final result = await _wordRepository.addWord(
        flashcardId, englishWord, japaneseMeaning);
    const int reads = 1;
    const int writes = 1;

    _printUsage('addWord', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'addWord',
      readCount: reads,
      writeCount: writes,
    );
    return result;
  }

  @override
  Future<void> updateWord(String flashcardId, String wordId, String newWord,
      String newMeaning) async {
    await _wordRepository.updateWord(flashcardId, wordId, newWord, newMeaning);
    const int reads = 0;
    const int writes = 1;

    _printUsage('updateWord', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'updateWord',
      readCount: reads,
      writeCount: writes,
    );
  }

  @override
  Future<void> deleteWord(String flashcardId, String wordId) async {
    await _wordRepository.deleteWord(flashcardId, wordId);
    const int reads = 0;
    const int writes = 1;

    _printUsage('deleteWord', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'deleteWord',
      readCount: reads,
      writeCount: writes,
    );
  }

  @override
  Future<List<Word>> getKnownWords(String flashcardId) async {
    final result = await _wordRepository.getKnownWords(flashcardId);
    const int reads = 1;
    const int writes = 0;

    _printUsage('getKnownWords', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'getKnownWords',
      readCount: reads,
      writeCount: writes,
    );
    return result;
  }

  @override
  Future<List<Word>> getUnknownWords(String flashcardId) async {
    final result = await _wordRepository.getUnknownWords(flashcardId);
    const int reads = 1;
    const int writes = 0;

    _printUsage('getUnknownWords', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'getUnknownWords',
      readCount: reads,
      writeCount: writes,
    );
    return result;
  }

  @override
  Future<void> addCorrectAt(String flashcardId, String wordId) async {
    await _wordRepository.addCorrectAt(flashcardId, wordId);
    const int reads = 0;
    const int writes = 1;

    _printUsage('addCorrectAt', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'addCorrectAt',
      readCount: reads,
      writeCount: writes,
    );
  }

  @override
  Future<void> addMistookAt(String flashcardId, String wordId) async {
    await _wordRepository.addMistookAt(flashcardId, wordId);
    const int reads = 0;
    const int writes = 1;

    _printUsage('addMistookAt', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'addMistookAt',
      readCount: reads,
      writeCount: writes,
    );
  }

  @override
  Future<void> toggleInProgress(String flashcardId, String wordId) async {
    await _wordRepository.toggleInProgress(flashcardId, wordId);
    const int reads = 1;
    const int writes = 1;

    _printUsage('toggleInProgress', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'toggleInProgress',
      readCount: reads,
      writeCount: writes,
    );
  }

  @override
  Future<void> resetInProgress(String? flashcardId) async {
    await _wordRepository.resetInProgress(flashcardId);
    // 単語数に応じてwrite countが変動するため、ここでは概算値を使用
    const int reads = 1;
    const int writes = 1; // 実際はもっと多くなる可能性がある

    _printUsage('resetInProgress', reads, writes);

    await _usageStatsRepository.logOperation(
      operationName: 'resetInProgress',
      readCount: reads,
      writeCount: writes,
    );
  }
}
