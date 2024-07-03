import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'firestore_model.g.dart';

@JsonSerializable()
class Word {
  final String id;
  final String word;
  final String meaning;
  final DateTime? addedOn;

  Word(
      {required this.id,
      required this.word,
      required this.meaning,
      this.addedOn});

  factory Word.fromJson(Map<String, dynamic> json) {
    json['addedOn'] =
        (json['addedOn'] as Timestamp?)?.toDate().toIso8601String();
    return _$WordFromJson(json);
  }

  Map<String, dynamic> toJson() => _$WordToJson(this);
}
