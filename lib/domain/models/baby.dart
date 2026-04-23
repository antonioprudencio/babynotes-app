import 'sync_status.dart';

class Baby {
  final String id;
  final String name;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  const Baby({
    required this.id,
    required this.name,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  Baby copyWith({String? id, String? name, DateTime? updatedAt, SyncStatus? syncStatus}) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory Baby.fromJson(Map<String, dynamic> json) => Baby(
        id: json['id'] as String,
        name: json['name'] as String,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime(2020),
        syncStatus: json['syncStatus'] != null
            ? SyncStatus.values.byName(json['syncStatus'] as String)
            : SyncStatus.pendingCreate,
      );

  factory Baby.fromApi(Map<String, dynamic> json) => Baby(
        id: json['id'] as String,
        name: json['name'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        syncStatus: SyncStatus.synced,
      );

  Map<String, dynamic> toApiJson() => {'id': id, 'name': name};
}
