// lib/model/firestore/usage_stats_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memo_words/model/firestore/flashcard_model.dart';
import 'package:memo_words/model/firestore/word_model.dart';
import 'package:memo_words/provider/word_provider.dart';
import 'package:memo_words/repository/word_repository.dart';

part 'usage_stats_model.g.dart';

@JsonSerializable()
class UsageStats {
  final String id;
  final String operationName;
  final int readCount;
  final int writeCount;
  final DateTime timestamp;

  UsageStats({
    required this.id,
    required this.operationName,
    required this.readCount,
    required this.writeCount,
    required this.timestamp,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) =>
      _$UsageStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UsageStatsToJson(this);
}
