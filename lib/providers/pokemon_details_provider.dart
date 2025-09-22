// lib/providers/pokemon_details_provider.dart

import 'package:flutter/material.dart';
import '../models/pokemon_details_model.dart';
import '../services/poke_api_service.dart';

class PokemonDetailsProvider extends ChangeNotifier {
  final PokeApiService _apiService = PokeApiService();
  final Map<String, PokemonDetails> _cache = {};

  // Retorna os detalhes de um Pokémon, buscando na API se não estiver em cache
  Future<PokemonDetails> getDetails(String id) async {
    // Se o pokémon já está no cache, retorna imediatamente
    if (_cache.containsKey(id)) {
      return _cache[id]!;
    }

    // Se não, busca na API
    final detailsJson = await _apiService.fetchPokemonDetails(id);
    final details = PokemonDetails.fromJson(detailsJson);

    // Armazena no cache para a próxima vez
    _cache[id] = details;

    // Retorna os detalhes recém-buscados
    return details;
  }
}