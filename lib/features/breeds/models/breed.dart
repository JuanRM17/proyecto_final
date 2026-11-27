class Breed {
  const Breed({
    required this.id,
    required this.name,
    required this.origin,
    required this.purpose,
    required this.weight,
    required this.description,
    required this.traits,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String origin;
  final String purpose;
  final String weight;
  final String description;
  final List<String> traits;
  final String imageUrl;

  factory Breed.fromMap(String id, Map<String, dynamic> map) {
    final rawTraits = map['traits'];
    return Breed(
      id: id,
      name: map['name'] as String? ?? id,
      origin: map['origin'] as String? ?? '',
      purpose: map['purpose'] as String? ?? '',
      weight: map['weight'] as String? ?? '',
      description: map['description'] as String? ?? '',
      traits: rawTraits is List
          ? rawTraits.map((e) => e.toString()).toList()
          : const [],
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }
}