// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'details_screen.dart'; // Importa a tela de detalhes

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos .watch para acessar la lista e ouvir por mudanças
    final favoritesProvider = context.watch<FavoritesProvider>();
    final favoritePokemons = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Favoritos'),
      ),
      body: favoritePokemons.isEmpty
          ? const Center(
              child: Text('Você ainda não tem Pokémon favoritos.'), // Mensagem para lista vazia
            )
          : ListView.builder(
              itemCount: favoritePokemons.length,
              itemBuilder: (context, index) {
                final pokemon = favoritePokemons[index];
                return ListTile(
                  leading: Image.network(pokemon.imageUrl),
                  title: Text(pokemon.name),
                  subtitle: Text('#${pokemon.id}'),
                  onTap: () { // Adiciona a capacidade de toque e navegação
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(pokemonId: pokemon.id.toString()),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}