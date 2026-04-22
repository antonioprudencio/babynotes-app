enum HygieneType {
  banho('Banho'),
  xixi('Xixi'),
  coco('Coco'),
  higieneBucal('Higiene bucal'),
  corteDeCabelo('Corte de cabelo'),
  corteDaUnha('Corte de unha'),
  lavagemNasal('Lavagem nasal');

  final String label;
  const HygieneType(this.label);
}

class Hygiene {
  final String id;
  final String babyId;
  final DateTime dateTime;
  final HygieneType type;
  final String? observation;

  const Hygiene({
    required this.id,
    required this.babyId,
    required this.dateTime,
    required this.type,
    this.observation,
  });

  Hygiene copyWith({
    String? id,
    String? babyId,
    DateTime? dateTime,
    HygieneType? type,
    String? observation,
  }) {
    return Hygiene(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      observation: observation ?? this.observation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'dateTime': dateTime.toIso8601String(),
        'type': type.name,
        'observation': observation,
      };

  factory Hygiene.fromJson(Map<String, dynamic> json) => Hygiene(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        type: HygieneType.values.byName(json['type'] as String),
        observation: json['observation'] as String?,
      );
}
