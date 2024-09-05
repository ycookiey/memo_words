import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'word_model.g.dart';

@JsonSerializable()
class Word {
  final String id;
  final String word;
  final String meaning;
  final DateTime? addedOn;
  final List<DateTime> correctAt;
  final List<DateTime> mistookAt;
  final bool inProgress;

  Word({
    required this.id,
    required this.word,
    required this.meaning,
    this.addedOn,
    required this.correctAt,
    required this.mistookAt,
    required this.inProgress,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      addedOn: (json['addedOn'] as Timestamp?)?.toDate(),
      mistookAt: (json['mistookAt'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      correctAt: (json['correctAt'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      inProgress: json['inProgress'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => _$WordToJson(this);

  Word copyWith({
    String? id,
    String? word,
    String? meaning,
    DateTime? addedOn,
    List<DateTime>? correctAt,
    List<DateTime>? mistookAt,
    bool? inProgress,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      addedOn: addedOn ?? this.addedOn,
      correctAt: correctAt ?? this.correctAt,
      mistookAt: mistookAt ?? this.mistookAt,
      inProgress: inProgress ?? this.inProgress,
    );
  }

  int getMistakeCount() {
    return mistookAt.length;
  }

  int getCorrectCount() {
    return correctAt.length;
  }
}
