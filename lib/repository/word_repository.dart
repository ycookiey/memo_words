import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_words/model/firestore/flashcard_model.dart';
import 'package:memo_words/model/firestore/word_model.dart';

class WordRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  WordRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : this.firestore = firestore ?? FirebaseFirestore.instance,
        this.firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<List<Flashcard>> getFlashcards() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      String userId = user.uid;

      print('Fetching flashcards for user: $userId'); // デバッグ用出力

      QuerySnapshot flashcardSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('flashcards')
          .get();

      print('Flashcard documents: ${flashcardSnapshot.docs.length}'); // デバッグ用出力

      return Future.wait(flashcardSnapshot.docs.map((doc) async {
        try {
          print('Processing flashcard document: ${doc.id}'); // デバッグ用出力

          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          // Fetch words for this flashcard
          QuerySnapshot wordSnapshot =
              await doc.reference.collection('words').get();

          print(
              'Words for flashcard ${doc.id}: ${wordSnapshot.docs.length}'); // デバッグ用出力

          List<Word> words = wordSnapshot.docs.map((wordDoc) {
            Map<String, dynamic> wordData =
                wordDoc.data() as Map<String, dynamic>;
            wordData['id'] = wordDoc.id;
            return Word.fromJson(wordData);
          }).toList();

          data['words'] = words;

          print('Flashcard data: $data'); // デバッグ用出力

          return Flashcard.fromJson(data);
        } catch (e, stackTrace) {
          print('Error processing flashcard ${doc.id}: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList());
    } catch (e, stackTrace) {
      print('Error in getFlashcards: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Flashcard> addFlashcard(String name) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    DocumentReference flashcardRef = await firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    DocumentSnapshot flashcardSnapshot = await flashcardRef.get();
    Map<String, dynamic> data =
        flashcardSnapshot.data() as Map<String, dynamic>;
    data['id'] = flashcardSnapshot.id;
    data['words'] = [];
    return Flashcard.fromJson(data);
  }

  Future<void> updateFlashcard(String flashcardId, String newName) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    await firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .doc(flashcardId)
        .update({
      'name': newName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    await firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .doc(flashcardId)
        .delete();
  }

  Future<Word> addWord(
      String flashcardId, String englishWord, String japaneseMeaning) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    DocumentReference wordRef = await firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .doc(flashcardId)
        .collection('words')
        .add({
      'word': englishWord,
      'meaning': japaneseMeaning,
      'addedOn': FieldValue.serverTimestamp(),
      'mistakenDates': [],
    });

    DocumentSnapshot wordSnapshot = await wordRef.get();
    Map<String, dynamic> data = wordSnapshot.data() as Map<String, dynamic>;
    data['id'] = wordSnapshot.id;
    return Word.fromJson(data);
  }

  Future<void> updateWord(String flashcardId, String wordId, String newWord,
      String newMeaning) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    await firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .doc(flashcardId)
        .collection('words')
        .doc(wordId)
        .update({
      'word': newWord,
      'meaning': newMeaning,
    });
  }

  Future<void> deleteWord(String flashcardId, String wordId) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    await firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .doc(flashcardId)
        .collection('words')
        .doc(wordId)
        .delete();
  }

  Future<void> addMistakenDate(String flashcardId, String wordId) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    // クライアント側で現在の日時を生成
    DateTime now = DateTime.now().toUtc();

    await firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .doc(flashcardId)
        .collection('words')
        .doc(wordId)
        .update({
      'mistakenDates': FieldValue.arrayUnion([Timestamp.fromDate(now)]),
    });
  }
}
