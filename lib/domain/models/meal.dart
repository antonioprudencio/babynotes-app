enum MealType {
  mamadeira('Mamadeira'),
  peito('Peito');

  final String label;
  const MealType(this.label);
}

class Meal {
  final String id;
  final String babyId;
  final DateTime dateTime;
  final MealType type;
  final double? volume;

  const Meal({
    required this.id,
    required this.babyId,
    required this.dateTime,
    required this.type,
    this.volume,
  });

  Meal copyWith({
    String? id,
    String? babyId,
    DateTime? dateTime,
    MealType? type,
    double? volume,
  }) {
    return Meal(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      volume: volume ?? this.volume,
    );
  }
}
