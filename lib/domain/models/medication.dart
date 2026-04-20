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
}
