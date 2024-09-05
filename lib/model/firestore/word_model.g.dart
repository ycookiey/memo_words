// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
      id: json['id'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      addedOn: json['addedOn'] == null
          ? null
          : DateTime.parse(json['addedOn'] as String),
      correctAt: (json['correctAt'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      mistookAt: (json['mistookAt'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      inProgress: json['inProgress'] as bool,
    );

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'meaning': instance.meaning,
      'addedOn': instance.addedOn?.toIso8601String(),
      'correctAt': instance.correctAt.map((e) => e.toIso8601String()).toList(),
      'mistookAt': instance.mistookAt.map((e) => e.toIso8601String()).toList(),
      'inProgress': instance.inProgress,
    };
