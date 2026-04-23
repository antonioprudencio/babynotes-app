import 'sync_status.dart';

class WeightRecord {
  final String id;
  final String babyId;
  final DateTime date;
  final double weightKg;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  const WeightRecord({
    required this.id,
    required this.babyId,
    required this.date,
    required this.weightKg,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  WeightRecord copyWith({
    String? id,
    String? babyId,
    DateTime? date,
    double? weightKg,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weightKg'] as num).toDouble(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime(2020),
        syncStatus: json['syncStatus'] != null
            ? SyncStatus.values.byName(json['syncStatus'] as String)
            : SyncStatus.pendingCreate,
      );

  factory WeightRecord.fromApi(Map<String, dynamic> json) => WeightRecord(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weightKg'] as num).toDouble(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.synced,
      );

  Map<String, dynamic> toApiJson() => {
        'babyId': babyId,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };
}
