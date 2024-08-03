import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'word_model.dart';

part 'flashcard_model.g.dart';

@JsonSerializable()
class Flashcard {
  final String id;
  final String name;
  final List<Word> words;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard({
    required this.id,
    required this.name,
    required this.words,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing Flashcard: $json');

      List<Word> parsedWords = [];
      if (json['words'] is List) {
        parsedWords = (json['words'] as List)
            .map((wordData) {
              if (wordData is Word) {
                return wordData;
              } else if (wordData is Map<String, dynamic>) {
                return Word.fromJson(wordData);
              } else {
                print('Invalid word data: $wordData');
                return null;
              }
            })
            .whereType<Word>()
            .toList();
      }

      return Flashcard(
        id: json['id'] as String,
        name: json['name'] as String,
        words: parsedWords,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      );
    } catch (e, stackTrace) {
      print('Error in Flashcard.fromJson: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$FlashcardToJson(this);

  Flashcard copyWith({
    String? id,
    String? name,
    List<Word>? words,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      name: name ?? this.name,
      words: words ?? this.words,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
