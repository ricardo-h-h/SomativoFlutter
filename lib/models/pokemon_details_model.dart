// lib/models/pokemon_details_model.dart

class PokemonDetails {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<String> abilities;

  PokemonDetails({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.abilities,
  });

  // Factory constructor para criar a instância a partir do JSON [cite: 466]
  factory PokemonDetails.fromJson(Map<String, dynamic> json) {
    return PokemonDetails(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['front_default'],
      types: (json['types'] as List)
          .map((typeInfo) => typeInfo['type']['name'] as String)
          .toList(),
      abilities: (json['abilities'] as List)
          .map((abilityInfo) => abilityInfo['ability']['name'] as String)
          .toList(),
    );
  }
}