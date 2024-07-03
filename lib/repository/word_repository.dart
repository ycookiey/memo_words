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
        'addedOn': DateTime.now(),
      });
    } else {
      DocumentReference listRef = querySnapshot.docs.first.reference;
      wordRef = listRef.collection('words').doc();
      await wordRef.set({
        'id': wordRef.id,
        'word': englishWord,
        'meaning': japaneseMeaning,
        'addedOn': DateTime.now(),
      });
    }

    return Word(
      id: wordRef.id,
      word: englishWord,
      meaning: japaneseMeaning,
      addedOn: DateTime.now(),
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

  Future<List<Word>> deleteWords(String id) async {
    await firestore.collection('words').doc(id).delete();
    return [];
  }

  Future<List<Word>> updateWords(String id, String word, String meaning) async {
    await firestore.collection('words').doc(id).update({
      'word': word,
      'meaning': meaning,
    });
    return [];
  }
}
