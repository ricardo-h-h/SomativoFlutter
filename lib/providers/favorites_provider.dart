// lib/providers/favorites_provider.dart

import 'package:flutter/material.dart';
import '../models/pokemon_details_model.dart';

// PASSO 1 do Provider: A classe que estende ChangeNotifier [cite: 117]
class FavoritesProvider extends ChangeNotifier {
  final List<PokemonDetails> _favorites = [];

  // Permite que a UI acesse a lista de favoritos de forma segura
  List<PokemonDetails> get favorites => _favorites;

  // Verifica se um Pokémon já está na lista de favoritos
  bool isFavorite(PokemonDetails pokemon) {
    return _favorites.any((fav) => fav.id == pokemon.id);
  }

  // Adiciona ou remove um Pokémon da lista
  void toggleFavorite(PokemonDetails pokemon) {
    if (isFavorite(pokemon)) {
      _favorites.removeWhere((fav) => fav.id == pokemon.id);
    } else {
      _favorites.add(pokemon);
    }
    // Avisa a todos os "ouvintes" que o estado mudou! [cite: 118, 1071]
    notifyListeners();
  }
}