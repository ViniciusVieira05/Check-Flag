import 'continente.dart';

class Country {
  final String code;
  final Map<String, String> names;
  final Continent continent;
  final bool isEasy;

  const Country({
    required this.code,
    required this.names,
    required this.continent,
    required this.isEasy,
  });

  factory Country.fromJson(Map<String, dynamic> json, Continent continent) {
    return Country(
      code: json['code'] as String,
      names: Map<String, String>.from(json['name'] as Map),
      continent: continent,
      isEasy: json['easy'] as bool,
    );
  }

  String get flagAsset => flagAssetFor(code);

  static String flagAssetFor(String code) => 'assets/bandeiras/$code.png';

  String nameIn(String languageCode) => names[languageCode] ?? names['pt']!;
}
