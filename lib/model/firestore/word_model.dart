import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'word_model.g.dart';

@JsonSerializable()
class Word {
  final String id;
  final String word;
  final String meaning;
  final DateTime? addedOn;
  final List<DateTime> mistakenDates;

  Word({
    required this.id,
    required this.word,
    required this.meaning,
    this.addedOn,
    List<DateTime>? mistakenDates,
  }) : this.mistakenDates = mistakenDates ?? [];

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      addedOn: (json['addedOn'] as Timestamp?)?.toDate(),
      mistakenDates: (json['mistakenDates'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => _$WordToJson(this);

  Word copyWith({
    String? id,
    String? word,
    String? meaning,
    DateTime? addedOn,
    List<DateTime>? mistakenDates,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      addedOn: addedOn ?? this.addedOn,
      mistakenDates: mistakenDates ?? this.mistakenDates,
    );
  }

  int getMistakeCount() {
    return mistakenDates.length;
  }
}
