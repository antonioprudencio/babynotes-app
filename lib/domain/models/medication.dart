import 'sync_status.dart';

enum DoseUnit {
  ml('ml', 'ML'),
  mg('mg', 'MG'),
  gotas('Gotas', 'GOTAS');

  final String label;
  final String apiName;
  const DoseUnit(this.label, this.apiName);

  static DoseUnit fromApiName(String name) =>
      DoseUnit.values.firstWhere((e) => e.apiName == name);
}

class Medication {
  final String id;
  final String babyId;
  final DateTime dateTime;
  final String name;
  final double dose;
  final DoseUnit unit;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  const Medication({
    required this.id,
    required this.babyId,
    required this.dateTime,
    required this.name,
    required this.dose,
    required this.unit,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  Medication copyWith({
    String? id,
    String? babyId,
    DateTime? dateTime,
    String? name,
    double? dose,
    DoseUnit? unit,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Medication(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      dateTime: dateTime ?? this.dateTime,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'dateTime': dateTime.toIso8601String(),
        'name': name,
        'dose': dose,
        'unit': unit.name,
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        name: json['name'] as String,
        dose: (json['dose'] as num).toDouble(),
        unit: DoseUnit.values.byName(json['unit'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime(2020),
        syncStatus: json['syncStatus'] != null
            ? SyncStatus.values.byName(json['syncStatus'] as String)
            : SyncStatus.pendingCreate,
      );

  factory Medication.fromApi(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        name: json['name'] as String,
        dose: (json['dose'] as num).toDouble(),
        unit: DoseUnit.fromApiName(json['type'] as String? ?? json['unit'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.synced,
      );

  Map<String, dynamic> toApiJson() => {
        'babyId': babyId,
        'dateTime': dateTime.toIso8601String(),
        'name': name,
        'dose': dose,
        'unit': unit.apiName,
      };
}
