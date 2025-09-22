// lib/screens/details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon_details_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/pokemon_details_provider.dart';

class DetailsScreen extends StatefulWidget {
  final String pokemonId;

  const DetailsScreen({super.key, required this.pokemonId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<PokemonDetails> _pokemonDetailsFuture;

  @override
  void initState() {
    super.initState();
    // A chamada para buscar os detalhes é iniciada aqui, uma única vez quando o widget é criado.
    // Usamos context.read (ou Provider.of com listen: false) dentro do initState,
    // pois não queremos que o initState "escute" por mudanças, apenas execute uma ação.
    _pokemonDetailsFuture = context.read<PokemonDetailsProvider>().getDetails(widget.pokemonId);
  }

  @override
  Widget build(BuildContext context) {
    // Usamos .watch aqui para que o ícone de favorito seja reconstruído
    // sempre que a lista de favoritos mudar.
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pokémon'),
        actions: [
          // Este FutureBuilder garante que o botão de favorito só apareça
          // depois que os detalhes do Pokémon forem carregados com sucesso.
          FutureBuilder<PokemonDetails>(
            future: _pokemonDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final pokemon = snapshot.data!;
                return IconButton(
                  icon: Icon(
                    favoritesProvider.isFavorite(pokemon)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: () {
                    // Usamos .read aqui porque estamos dentro de um callback (onPressed)
                    // e só queremos chamar uma função, sem registrar o widget para reconstrução.
                    context.read<FavoritesProvider>().toggleFavorite(pokemon);
                  },
                );
              }
              // Enquanto os dados não chegam, não mostra nada no lugar do botão.
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<PokemonDetails>(
        future: _pokemonDetailsFuture, // O FutureBuilder "escuta" o futuro que iniciamos no initState.
        builder: (context, snapshot) {
          // Enquanto os dados estão sendo buscados, mostra um indicador de carregamento.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se ocorrer um erro na busca, exibe uma mensagem.
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar detalhes: ${snapshot.error}'));
          }
          // Se os dados chegarem com sucesso, constrói a tela de detalhes.
          if (snapshot.hasData) {
            final details = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(details.imageUrl,
                        height: 200, width: 200, fit: BoxFit.cover),
                    const SizedBox(height: 16),
                    Text(
                      '#${details.id} - ${details.name.toUpperCase()}',
                      style:
                          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Tipos: ${details.types.join(', ')}'),
                    const SizedBox(height: 16),
                    Text('Habilidades: ${details.abilities.join(', ')}'),
                  ],
                ),
              ),
            );
          }
          // Caso não se encaixe em nenhum dos estados acima.
          return const Center(child: Text('Nenhum dado encontrado.'));
        },
      ),
    );
  }
}