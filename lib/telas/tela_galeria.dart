import 'package:flutter/material.dart';

import '../componentes/imagem_bandeira.dart';
import '../dados/repositorio_paises.dart';
import '../idiomas/textos.dart';
import '../modelos/continente.dart';
import '../modelos/pais.dart';
import '../servicos/servico_preferencias.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _search = '';
  Continent? _continent;

  String get _lang => SettingsService.instance.language;

  String _normalize(String text) {
    const withAccent = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const withoutAccent = 'aaaaaeeeeiiiiooooouuuucn';
    var result = text.toLowerCase();
    for (int i = 0; i < withAccent.length; i++) {
      result = result.replaceAll(withAccent[i], withoutAccent[i]);
    }
    return result;
  }

  List<Country> get _filtered {
    final repo = CountryRepository.instance;
    final countries = _continent == null ? repo.all : repo.byContinent(_continent!);
    final search = _normalize(_search.trim());

    final result = countries.where((c) => _normalize(c.nameIn(_lang)).contains(search)).toList();
    result.sort((a, b) => _normalize(a.nameIn(_lang)).compareTo(_normalize(b.nameIn(_lang))));
    return result;
  }

  void _showCountry(Country country) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(country.nameIn(_lang), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlagImage(asset: country.flagAsset, width: 240),
            const SizedBox(height: 16),
            Text('${tr('continentLabel')}: ${continentName(country.continent)}'),
            Text('${tr('difficultySection')}: ${tr(country.isEasy ? 'easy' : 'hard')}'),
            Text('${tr('codeLabel')}: ${country.code.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('close'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final countries = _filtered;

    return Scaffold(
      appBar: AppBar(title: Text(tr('gallery'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                labelText: tr('searchCountry'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tr('all')),
                    selected: _continent == null,
                    onSelected: (_) => setState(() => _continent = null),
                  ),
                ),
                for (final continent in Continent.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(continentName(continent)),
                      selected: _continent == continent,
                      onSelected: (_) => setState(() => _continent = continent),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr('countriesCount', {'n': '${countries.length}'}),
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
          Expanded(
            child: countries.isEmpty
                ? Center(child: Text(tr('noCountryFound')))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final country = countries[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showCountry(country),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(child: FlagImage(asset: country.flagAsset)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              country.nameIn(_lang),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
