enum Continent {
  africa('africa'),
  america('america'),
  asia('asia'),
  europe('europe'),
  oceania('oceania');

  const Continent(this.jsonKey);

  final String jsonKey;
}
