import 'sync_status.dart';

enum MealType {
  mamadeira('Mamadeira', 'MAMADEIRA'),
  peito('Peito', 'PEITO');

  final String label;
  final String apiName;
  const MealType(this.label, this.apiName);

  static MealType fromApiName(String name) =>
      MealType.values.firstWhere((e) => e.apiName == name);
}

class Meal {
  final String id;
  final String babyId;
  final DateTime dateTime;
  final MealType type;
  final double? volume;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  const Meal({
    required this.id,
    required this.babyId,
    required this.dateTime,
    required this.type,
    this.volume,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  Meal copyWith({
    String? id,
    String? babyId,
    DateTime? dateTime,
    MealType? type,
    double? volume,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Meal(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      volume: volume ?? this.volume,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'dateTime': dateTime.toIso8601String(),
        'type': type.name,
        'volume': volume,
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        type: MealType.values.byName(json['type'] as String),
        volume: json['volume'] != null ? (json['volume'] as num).toDouble() : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime(2020),
        syncStatus: json['syncStatus'] != null
            ? SyncStatus.values.byName(json['syncStatus'] as String)
            : SyncStatus.pendingCreate,
      );

  factory Meal.fromApi(Map<String, dynamic> json) => Meal(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        type: MealType.fromApiName(json['type'] as String),
        volume: json['volume'] != null ? (json['volume'] as num).toDouble() : null,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.synced,
      );

  Map<String, dynamic> toApiJson() => {
        'babyId': babyId,
        'dateTime': dateTime.toIso8601String(),
        'type': type.apiName,
        'volume': volume,
      };
}
