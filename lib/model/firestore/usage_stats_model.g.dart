// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageStats _$UsageStatsFromJson(Map<String, dynamic> json) => UsageStats(
      id: json['id'] as String,
      operationName: json['operationName'] as String,
      readCount: json['readCount'] as int,
      writeCount: json['writeCount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$UsageStatsToJson(UsageStats instance) =>
    <String, dynamic>{
      'id': instance.id,
      'operationName': instance.operationName,
      'readCount': instance.readCount,
      'writeCount': instance.writeCount,
      'timestamp': instance.timestamp.toIso8601String(),
    };
