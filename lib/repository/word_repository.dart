import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_words/model/firestore/firestore_model.dart';

class WordRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  WordRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : this.firestore = firestore ?? FirebaseFirestore.instance,
        this.firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<Word> addWord(
      String listName, String englishWord, String japaneseMeaning) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    CollectionReference listsRef =
        firestore.collection('users').doc(userId).collection('wordLists');

    var querySnapshot = await listsRef.where('name', isEqualTo: listName).get();

    DocumentReference wordRef;
    if (querySnapshot.docs.isEmpty) {
      DocumentReference newListRef = listsRef.doc();
      wordRef = newListRef.collection('words').doc();
      await newListRef.set({
        'name': listName,
      });
      await wordRef.set({
        'id': wordRef.id,
        'word': englishWord,
        'meaning': japaneseMeaning,
        'addedOn': FieldValue.serverTimestamp(),
        'mistakenDates': [],
      });
    } else {
      DocumentReference listRef = querySnapshot.docs.first.reference;
      wordRef = listRef.collection('words').doc();
      await wordRef.set({
        'id': wordRef.id,
        'word': englishWord,
        'meaning': japaneseMeaning,
        'addedOn': FieldValue.serverTimestamp(),
        'mistakenDates': [],
      });
    }

    return Word(
      id: wordRef.id,
      word: englishWord,
      meaning: japaneseMeaning,
      addedOn: DateTime.now(),
      mistakenDates: [],
    );
  }

  Future<List<Word>> getWords() async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    List<Word> words = [];
    QuerySnapshot listSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('wordLists')
        .get();

    for (var listDoc in listSnapshot.docs) {
      QuerySnapshot wordSnapshot =
          await listDoc.reference.collection('words').get();
      for (var wordDoc in wordSnapshot.docs) {
        words.add(Word.fromJson(wordDoc.data() as Map<String, dynamic>));
      }
    }

    return words;
  }

  Future<void> deleteWord(String wordId) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    QuerySnapshot listSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('wordLists')
        .get();

    for (var listDoc in listSnapshot.docs) {
      QuerySnapshot wordSnapshot = await listDoc.reference
          .collection('words')
          .where('id', isEqualTo: wordId)
          .get();

      if (wordSnapshot.docs.isNotEmpty) {
        await wordSnapshot.docs.first.reference.delete();
        break;
      }
    }
  }

  Future<void> updateWord(
      String wordId, String newWord, String newMeaning) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    QuerySnapshot listSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('wordLists')
        .get();

    for (var listDoc in listSnapshot.docs) {
      QuerySnapshot wordSnapshot = await listDoc.reference
          .collection('words')
          .where('id', isEqualTo: wordId)
          .get();

      if (wordSnapshot.docs.isNotEmpty) {
        await wordSnapshot.docs.first.reference.update({
          'word': newWord,
          'meaning': newMeaning,
        });
        break;
      }
    }
  }

  Future<void> addMistakenDate(String wordId) async {
    User? user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    String userId = user.uid;

    QuerySnapshot listSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('wordLists')
        .get();

    for (var listDoc in listSnapshot.docs) {
      QuerySnapshot wordSnapshot = await listDoc.reference
          .collection('words')
          .where('id', isEqualTo: wordId)
          .get();

      if (wordSnapshot.docs.isNotEmpty) {
        await wordSnapshot.docs.first.reference.update({
          'mistakenDates':
              FieldValue.arrayUnion([FieldValue.serverTimestamp()]),
        });
        break;
      }
    }
  }
}
