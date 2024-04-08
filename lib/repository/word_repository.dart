import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memo_words/model/firestore/firestore_model.dart';

class WordRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Word?> addWord(String word, String meaning) async {
    var addedOn = DateTime.now();
    var documentReference = await _firestore.collection('words').add({
      'word': word,
      'meaning': meaning,
      'addedOn': addedOn,
    });
    var documentSnapshot = await documentReference.get();
    return Word(
      id: documentSnapshot.id,
      word: word,
      meaning: meaning,
      addedOn: addedOn,
    );
  }

  Future<List<Word>> getWords() async {
    var querySnapshot = await _firestore.collection('words').get();
    return querySnapshot.docs.map((doc) {
      return Word(
        id: doc.id,
        word: doc['word'],
        meaning: doc['meaning'],
        addedOn: doc['addedOn'].toDate(),
      );
    }).toList();
  }

  Future<List<Word>> deleteWords(String id) async {
    await _firestore.collection('words').doc(id).delete();
    return [];
  }
}
