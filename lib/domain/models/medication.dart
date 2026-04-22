enum DoseUnit {
  ml('ml'),
  mg('mg'),
  gotas('Gotas');

  final String label;
  const DoseUnit(this.label);
}

class Medication {
  final String id;
  final String babyId;
  final DateTime dateTime;
  final String name;
  final double dose;
  final DoseUnit unit;

  const Medication({
    required this.id,
    required this.babyId,
    required this.dateTime,
    required this.name,
    required this.dose,
    required this.unit,
  });

  Medication copyWith({
    String? id,
    String? babyId,
    DateTime? dateTime,
    String? name,
    double? dose,
    DoseUnit? unit,
  }) {
    return Medication(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      dateTime: dateTime ?? this.dateTime,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'dateTime': dateTime.toIso8601String(),
        'name': name,
        'dose': dose,
        'unit': unit.name,
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        name: json['name'] as String,
        dose: (json['dose'] as num).toDouble(),
        unit: DoseUnit.values.byName(json['unit'] as String),
      );
}
