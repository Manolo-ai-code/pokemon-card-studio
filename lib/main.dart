import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pokemon.dart';

void main() {
  runApp(const PokemonCardApp());
}

class PokemonCardApp extends StatelessWidget {
  const PokemonCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon Card Studio',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF101813),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9F45B),
          brightness: Brightness.dark,
        ),
      ),
      home: const CardSearchPage(),
    );
  }
}

class CardSearchPage extends StatefulWidget {
  const CardSearchPage({super.key});

  @override
  State<CardSearchPage> createState() => _CardSearchPageState();
}

class _CardSearchPageState extends State<CardSearchPage> {
  final TextEditingController _controller = TextEditingController(text: 'shelmet');
  
  Pokemon? _pokemon;
  bool _isLoading = false;
  String? _errorMessage;

  static const lime = Color(0xFFD9F45B);
  static const ink = Color(0xFF10221F);
  static const panel = Color(0xFF19312D);
  static const white = Color(0xFFF5F7EE);
  static const muted = Color(0xFFB3C4B8);

  @override
  void initState() {
    super.initState();
    _fetchPokemon(_controller.text);
  }

  Future<void> _fetchPokemon(String query) async {
    final formattedName = query.trim().toLowerCase();
    if (formattedName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a Pokémon name.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$formattedName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          _pokemon = Pokemon.fromJson(data);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Pokémon "$formattedName" not found. Please check the spelling.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load Pokémon (Error code: ${response.statusCode}).';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error occurred. Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  String pretty(String value) => value
      .split('-')
      .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
      .join(' ');

  Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bug': return const Color(0xFF9DCB42);
      case 'fire': return const Color(0xFFFF795B);
      case 'water': return const Color(0xFF64B5F6);
      case 'grass': return const Color(0xFF72CE86);
      case 'electric': return const Color(0xFFFFD54F);
      case 'poison': return const Color(0xFFC58BFA);
      case 'psychic': return const Color(0xFFF48FB1);
      case 'ice': return const Color(0xFF80DEEA);
      case 'dragon': return const Color(0xFF9C91FF);
      case 'fairy': return const Color(0xFFFFB6D5);
      default: return lime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ink,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.catching_pokemon, color: lime, size: 28),
            SizedBox(width: 10),
            Text(
              'POKÉMON CARD STUDIO',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 540;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: narrow ? 12 : 32,
                vertical: 28,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 510),
                child: Column(
                  children: [
                    // Search Bar Section
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !_isLoading,
                            style: const TextStyle(color: white, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Enter Pokémon Name',
                              labelStyle: const TextStyle(color: muted),
                              filled: true,
                              fillColor: panel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.search, color: lime),
                            ),
                            onSubmitted: (value) => _fetchPokemon(value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lime,
                            foregroundColor: ink,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : () => _fetchPokemon(_controller.text),
                          child: const Text('SEARCH', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // State handling: Loading, Error, or Card Display
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(color: lime),
                      )
                    else if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: white, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_pokemon != null)
                      _buildCard(narrow, _pokemon!),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(bool narrow, Pokemon pokemon) {
    return Container(
      padding: EdgeInsets.all(narrow ? 7 : 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FF8B), Color(0xFFB9D940), Color(0xFFE5F76C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: lime.withOpacity(0.13),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ink,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(narrow ? 12 : 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(narrow, pokemon),
              const SizedBox(height: 14),
              _buildArtwork(narrow, pokemon),
              const SizedBox(height: 5),
              _buildInfoStrip(pokemon),
              const SizedBox(height: 20),
              _buildAbilities(pokemon),
              const SizedBox(height: 15),
              Container(height: 2, color: lime),
              const SizedBox(height: 10),
              _buildMoves(pokemon),
              const SizedBox(height: 15),
              _buildFooter(pokemon),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool narrow, Pokemon pokemon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.white, Color(0xFFB9C3BE)]),
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Text(
            'BASIC',
            style: TextStyle(
              color: Color(0xFF23312B),
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            pretty(pokemon.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: white,
              fontSize: narrow ? 23 : 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '#${pokemon.id.toString().padLeft(3, '0')}',
              style: const TextStyle(
                color: lime,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const Text(
              'POKÉDEX',
              style: TextStyle(color: muted, fontSize: 8, letterSpacing: 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArtwork(bool narrow, Pokemon pokemon) {
    return Container(
      height: narrow ? 230 : 285,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: lime, width: 3),
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5F8D68), Color(0xFF294E3D), Color(0xFF152B25)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 15,
            bottom: 12,
            child: Text(
              'SPECIMEN  #${pokemon.id}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 8,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: pokemon.spriteUrl.isEmpty
                ? const Icon(Icons.catching_pokemon, size: 110, color: lime)
                : Image.network(
                    pokemon.spriteUrl,
                    fit: BoxFit.contain,
                    width: narrow ? 210 : 255,
                    height: narrow ? 210 : 255,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.catching_pokemon,
                      size: 100,
                      color: lime,
                    ),
                  ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Wrap(
              spacing: 5,
              children: pokemon.types.isEmpty
                  ? [_typeBadge('Unknown')]
                  : pokemon.types.map(_typeBadge).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor(type),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        pretty(type).toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF15221B),
          fontWeight: FontWeight.w900,
          fontSize: 9,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildInfoStrip(Pokemon pokemon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFF2F4ED), Color(0xFFBCC7BC)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(7)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 13,
        runSpacing: 5,
        children: [
          _infoText('No. ${pokemon.id}'),
          _infoText('HT: ${(pokemon.height / 10).toStringAsFixed(1)} m'),
          _infoText('WT: ${(pokemon.weight / 10).toStringAsFixed(1)} kg'),
        ],
      ),
    );
  }

  Widget _infoText(String value) {
    return Text(
      value,
      style: const TextStyle(
        color: Color(0xFF1B2A22),
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildAbilities(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ABILITIES',
          style: TextStyle(
            color: lime,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        if (pokemon.abilities.isEmpty)
          const Text('No abilities available.', style: TextStyle(color: muted, fontSize: 12)),
        ...pokemon.abilities.map(
          (ability) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 72),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                  decoration: BoxDecoration(
                    color: ability.isHidden ? const Color(0xFF4B5871) : const Color(0xFFB82E40),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Text(
                    ability.isHidden ? 'HIDDEN' : 'ABILITY',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pretty(ability.name),
                        style: const TextStyle(
                          color: lime,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ability.isHidden
                            ? 'Hidden ability • Slot ${ability.slot}'
                            : 'Ability slot ${ability.slot}',
                        style: const TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoves(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'MOVES',
                style: TextStyle(
                  color: lime,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            Text(
              '${pokemon.moves.length} LISTED',
              style: const TextStyle(color: muted, fontSize: 9, letterSpacing: 1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (pokemon.moves.isEmpty)
          const Text('No moves available.', style: TextStyle(color: muted, fontSize: 12)),
        ...pokemon.moves.asMap().entries.map((entry) {
          final move = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.key.isEven ? lime : const Color(0xFFE5E9E2),
                  ),
                  child: Icon(
                    entry.key.isEven ? Icons.bug_report : Icons.auto_awesome,
                    color: ink,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    pretty(move.name),
                    style: const TextStyle(
                      color: white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 12, color: muted),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooter(Pokemon pokemon) {
    return Container(
      padding: const EdgeInsets.only(top: 13),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: lime, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _footerBadge(Icons.bolt, '${pokemon.baseExperience} BASE XP'),
              _footerBadge(Icons.inventory_2_outlined, '${pokemon.heldItems.length} HELD ITEMS'),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.catching_pokemon, color: lime, size: 27),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '${pretty(pokemon.name)}, Pokédex entry #${pokemon.id}. '
                  'Height and weight are displayed using metric units.',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: lime.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: lime, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}