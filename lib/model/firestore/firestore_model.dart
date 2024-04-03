import 'package:freezed_annotation/freezed_annotation.dart';

part 'firestore_model.freezed.dart';
part 'firestore_model.g.dart';

@freezed
class Word with _$Word {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory Word({
    required String id,
    required String word,
    required String meaning,
    DateTime? addedOn,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
