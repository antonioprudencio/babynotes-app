import 'sync_status.dart';

enum HygieneType {
  banho('Banho', 'BANHO'),
  xixi('Xixi', 'XIXI'),
  coco('Coco', 'COCO'),
  higieneBucal('Higiene bucal', 'HIGIENE_BUCAL'),
  corteDeCabelo('Corte de cabelo', 'CORTE_DE_CABELO'),
  corteDaUnha('Corte de unha', 'CORTE_DE_UNHA'),
  lavagemNasal('Lavagem nasal', 'LAVAGEM_NASAL');

  final String label;
  final String apiName;
  const HygieneType(this.label, this.apiName);

  static HygieneType fromApiName(String name) =>
      HygieneType.values.firstWhere((e) => e.apiName == name);
}

class Hygiene {
  final String id;
  final String babyId;
  final DateTime dateTime;
  final HygieneType type;
  final String? observation;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  const Hygiene({
    required this.id,
    required this.babyId,
    required this.dateTime,
    required this.type,
    this.observation,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  Hygiene copyWith({
    String? id,
    String? babyId,
    DateTime? dateTime,
    HygieneType? type,
    String? observation,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Hygiene(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      observation: observation ?? this.observation,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'dateTime': dateTime.toIso8601String(),
        'type': type.name,
        'observation': observation,
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory Hygiene.fromJson(Map<String, dynamic> json) => Hygiene(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        type: HygieneType.values.byName(json['type'] as String),
        observation: json['observation'] as String?,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime(2020),
        syncStatus: json['syncStatus'] != null
            ? SyncStatus.values.byName(json['syncStatus'] as String)
            : SyncStatus.pendingCreate,
      );

  factory Hygiene.fromApi(Map<String, dynamic> json) => Hygiene(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        type: HygieneType.fromApiName(json['type'] as String),
        observation: json['observation'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.synced,
      );

  Map<String, dynamic> toApiJson() => {
        'babyId': babyId,
        'dateTime': dateTime.toIso8601String(),
        'type': type.apiName,
        'observation': observation,
      };
}
