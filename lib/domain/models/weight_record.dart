class WeightRecord {
  final String id;
  final String babyId;
  final DateTime date;
  final double weightKg;

  const WeightRecord({
    required this.id,
    required this.babyId,
    required this.date,
    required this.weightKg,
  });

  WeightRecord copyWith({
    String? id,
    String? babyId,
    DateTime? date,
    double? weightKg,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
