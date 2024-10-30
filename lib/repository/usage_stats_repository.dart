import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsageStatsRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  UsageStatsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : this.firestore = firestore ?? FirebaseFirestore.instance,
        this.firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// 操作の使用状況を記録
  Future<void> logOperation({
    required String operationName,
    required int readCount,
    required int writeCount,
  }) async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('usage_stats')
          .add({
        'operationName': operationName,
        'readCount': readCount,
        'writeCount': writeCount,
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD形式
        'estimatedCost': _calculateCost(readCount, writeCount),
      });
    } catch (e) {
      print('Error logging operation: $e');
      rethrow;
    }
  }

  /// 全期間の使用状況サマリーを取得
  Future<Map<String, Map<String, int>>> getUsageStatsSummary() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('usage_stats')
          .get();

      return _processUsageSnapshot(snapshot);
    } catch (e) {
      print('Error getting usage summary: $e');
      rethrow;
    }
  }

  /// 日別の使用状況サマリーを取得
  Future<Map<String, Map<String, int>>> getDailyUsageStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      Query<Map<String, dynamic>> query =
          firestore.collection('users').doc(user.uid).collection('usage_stats');

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0]);
      }

      final snapshot = await query.get();
      return _processDailyUsageSnapshot(snapshot);
    } catch (e) {
      print('Error getting daily usage stats: $e');
      rethrow;
    }
  }

  /// 今日の使用状況を取得
  Future<Map<String, int>> getTodayUsageStats() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('usage_stats')
          .where('date', isEqualTo: today)
          .get();

      return _processTodayUsageSnapshot(snapshot);
    } catch (e) {
      print('Error getting today\'s usage stats: $e');
      rethrow;
    }
  }

  /// スナップショットから使用状況サマリーを作成
  Map<String, Map<String, int>> _processUsageSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    Map<String, Map<String, int>> summary = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final operationName = data['operationName'] as String;
      final readCount = data['readCount'] as int;
      final writeCount = data['writeCount'] as int;

      if (!summary.containsKey(operationName)) {
        summary[operationName] = {
          'reads': 0,
          'writes': 0,
          'totalOperations': 0,
        };
      }
      summary[operationName]!['reads'] =
          (summary[operationName]!['reads'] ?? 0) + readCount;
      summary[operationName]!['writes'] =
          (summary[operationName]!['writes'] ?? 0) + writeCount;
      summary[operationName]!['totalOperations'] =
          (summary[operationName]!['totalOperations'] ?? 0) + 1;
    }

    return summary;
  }

  /// スナップショットから日別使用状況を作成
  Map<String, Map<String, int>> _processDailyUsageSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    Map<String, Map<String, int>> dailyStats = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = data['date'] as String;
      final readCount = data['readCount'] as int;
      final writeCount = data['writeCount'] as int;

      if (!dailyStats.containsKey(date)) {
        dailyStats[date] = {
          'reads': 0,
          'writes': 0,
          'totalOperations': 0,
        };
      }
      dailyStats[date]!['reads'] =
          (dailyStats[date]!['reads'] ?? 0) + readCount;
      dailyStats[date]!['writes'] =
          (dailyStats[date]!['writes'] ?? 0) + writeCount;
      dailyStats[date]!['totalOperations'] =
          (dailyStats[date]!['totalOperations'] ?? 0) + 1;
    }

    return dailyStats;
  }

  /// スナップショットから今日の使用状況を作成
  Map<String, int> _processTodayUsageSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    int totalReads = 0;
    int totalWrites = 0;
    int totalOperations = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalReads += data['readCount'] as int;
      totalWrites += data['writeCount'] as int;
      totalOperations++;
    }

    return {
      'reads': totalReads,
      'writes': totalWrites,
      'totalOperations': totalOperations,
    };
  }

  /// 無料枠の使用率を計算（パーセンテージ）
  Future<Map<String, double>> getFreeTierUsagePercentage() async {
    try {
      final todayStats = await getTodayUsageStats();

      // Firebaseの無料枠（1日あたり）
      const int dailyFreeReads = 50000;
      const int dailyFreeWrites = 20000;

      return {
        'reads': (todayStats['reads']! / dailyFreeReads) * 100,
        'writes': (todayStats['writes']! / dailyFreeWrites) * 100,
      };
    } catch (e) {
      print('Error calculating free tier usage: $e');
      rethrow;
    }
  }

  /// 使用コストを計算（米ドル）
  double _calculateCost(int readCount, int writeCount) {
    // Firebaseの料金設定（2024年4月現在）
    const double readCostPer100k = 0.036; // $0.036 per 100,000 reads
    const double writeCostPer100k = 0.108; // $0.108 per 100,000 writes

    final readCost = (readCount * readCostPer100k) / 100000;
    final writeCost = (writeCount * writeCostPer100k) / 100000;

    return readCost + writeCost;
  }

  /// 期間指定での総コストを計算
  Future<double> getTotalCost({DateTime? startDate, DateTime? endDate}) async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      Query<Map<String, dynamic>> query =
          firestore.collection('users').doc(user.uid).collection('usage_stats');

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0]);
      }

      final snapshot = await query.get();

      double totalCost = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final readCount = data['readCount'] as int;
        final writeCount = data['writeCount'] as int;
        totalCost += _calculateCost(readCount, writeCount);
      }

      return totalCost;
    } catch (e) {
      print('Error calculating total cost: $e');
      rethrow;
    }
  }

  /// 使用状況履歴をクリア（主にテスト用）
  Future<void> clearUsageStats() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('usage_stats')
          .get();

      final batch = firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing usage stats: $e');
      rethrow;
    }
  }
}
