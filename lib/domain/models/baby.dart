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
}
