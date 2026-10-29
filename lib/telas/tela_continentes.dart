import 'package:flutter/material.dart';

import '../componentes/imagem_bandeira.dart';
import '../dados/repositorio_paises.dart';
import '../idiomas/textos.dart';
import '../modelos/configuracao_jogo.dart';
import '../modelos/continente.dart';
import '../modelos/pais.dart';
import '../servicos/servico_preferencias.dart';
import 'tela_jogo.dart';

class ContinentScreen extends StatelessWidget {
  const ContinentScreen({super.key});

  static const Map<Continent, String> _exampleFlag = {
    Continent.africa: 'za',
    Continent.america: 'br',
    Continent.asia: 'jp',
    Continent.europe: 'fr',
    Continent.oceania: 'au',
  };

  int _countFor(Continent continent) {
    final countries = CountryRepository.instance.byContinent(continent);
    if (SettingsService.instance.difficulty == Difficulty.easy) {
      return countries.where((c) => c.isEasy).length;
    }
    return countries.length;
  }

  void _start(BuildContext context, Continent continent) {
    final settings = SettingsService.instance;
    final config = GameConfig(
      continent: continent,
      totalSeconds: settings.seconds,
      difficulty: settings.difficulty,
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(config: config)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('chooseContinent'))),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          for (final continent in Continent.values)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + continent.index * 150),
              curve: Curves.easeOut,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(offset: Offset(0, 40 * (1 - value)), child: child),
              ),
              child: Card(
                child: ListTile(
                  leading: FlagImage(asset: Country.flagAssetFor(_exampleFlag[continent]!), width: 48),
                  title: Text(continentName(continent)),
                  subtitle: Text(tr('countriesCount', {'n': '${_countFor(continent)}'})),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _start(context, continent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
