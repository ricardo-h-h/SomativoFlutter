// lib/services/poke_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokeApiService {
  final String _baseUrl = 'https://pokeapi.co/api/v2/';

  // Função para buscar uma lista de Pokémon com paginação (offset)
  Future<List<Pokemon>> fetchPokemonList({int offset = 0, int limit = 20}) async {
    final url = Uri.parse('${_baseUrl}pokemon?offset=$offset&limit=$limit');
    final response = await http.get(url); // Faz a requisição HTTP [cite: 1168]

    if (response.statusCode == 200) { // Verifica se a requisição foi bem-sucedida [cite: 1169]
      final data = jsonDecode(response.body); // Decodifica a resposta JSON [cite: 1170]
      final List<dynamic> results = data['results'];
      return results.map((json) => Pokemon.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar a lista de Pokémon.'); // Lança uma exceção em caso de erro [cite: 263]
    }
  }

  Future<Map<String, dynamic>> fetchPokemonDetails(String id) async {
    final url = Uri.parse('${_baseUrl}pokemon/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retorna o JSON completo dos detalhes
    } else {
      throw Exception('Falha ao carregar detalhes do Pokémon.');
    }
  }
  
}