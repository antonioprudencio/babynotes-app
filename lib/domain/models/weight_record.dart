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

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weightKg'] as num).toDouble(),
      );
}
