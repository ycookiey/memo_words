import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'firestore_model.g.dart';

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
    json['addedOn'] =
        (json['addedOn'] as Timestamp?)?.toDate().toIso8601String();
    json['mistakenDates'] = (json['mistakenDates'] as List<dynamic>?)
            ?.map((timestamp) =>
                (timestamp as Timestamp).toDate().toIso8601String())
            .toList() ??
        [];
    return _$WordFromJson(json);
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
}
