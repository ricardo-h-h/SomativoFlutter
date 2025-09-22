// lib/screens/pokedex_screen.dart

import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/poke_api_service.dart';
import 'details_screen.dart';
import 'favorites_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final PokeApiService _apiService = PokeApiService();
  List<Pokemon> _pokemonList = [];
  int _offset = 0;
  bool _isLoading = false;
  bool _isInitialLoad = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialPokemon();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPokemon() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final initialList = await _apiService.fetchPokemonList(offset: _offset);
      setState(() {
        _pokemonList = initialList;
        _offset += 20;
        _isInitialLoad = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePokemon() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final newList = await _apiService.fetchPokemonList(offset: _offset);
      setState(() {
        _pokemonList.addAll(newList);
        _offset += 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchPokemon() async {
    final searchTerm = _searchController.text.trim().toLowerCase();
    if (searchTerm.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pokemonDetails = await _apiService.fetchPokemonDetails(searchTerm);
      final pokemonId = pokemonDetails['id'].toString();

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(pokemonId: pokemonId),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pokémon não encontrado. Verifique o nome ou número.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: _isInitialLoad && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Nome ou número do Pokémon',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _searchPokemon(), // Permite buscar com o "Enter" do teclado
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _searchPokemon,
                        child: const Text('Buscar'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 3 / 2.5,
                    ),
                    itemCount: _pokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = _pokemonList[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(pokemonId: pokemon.id),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                pokemon.imageUrl,
                                height: 80,
                                width: 80,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(pokemon.name),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading && !_isInitialLoad)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loadMorePokemon,
                    child: const Text('Carregar Mais'),
                  ),
                ),
              ],
            ),
    );
  }
}