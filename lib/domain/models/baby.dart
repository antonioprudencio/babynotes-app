class Baby {
  final String id;
  final String name;

  const Baby({required this.id, required this.name});

  Baby copyWith({String? id, String? name}) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Baby.fromJson(Map<String, dynamic> json) =>
      Baby(id: json['id'] as String, name: json['name'] as String);
}
