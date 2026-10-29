import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../modelos/continente.dart';
import '../modelos/pais.dart';

class CountryRepository {
  CountryRepository._();
  static final CountryRepository instance = CountryRepository._();

  final Map<Continent, List<Country>> _byContinent = {};

  Future<void> load() async {
    if (_byContinent.isNotEmpty) return;

    final text = await rootBundle.loadString('assets/dados/paises.json');
    final Map<String, dynamic> data = jsonDecode(text);

    for (final continent in Continent.values) {
      final List items = data[continent.jsonKey] as List;
      _byContinent[continent] = items
          .map((item) => Country.fromJson(item as Map<String, dynamic>, continent))
          .toList();
    }
  }

  List<Country> byContinent(Continent continent) => _byContinent[continent] ?? [];

  List<Country> get all => _byContinent.values.expand((list) => list).toList();
}
