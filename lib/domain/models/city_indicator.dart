enum CityIndicator {
  foodSecurity('Food security'),
  povertyReduction('Poverty reduction'),
  publicHealth('Public health'),
  educationQuality('Education quality'),
  waterSecurity('Water security'),
  employmentQuality('Employment quality'),
  urbanResilience('Urban resilience'),
  climateResilience('Climate resilience'),
  budgetHealth('Budget health'),
  publicTrust('Public trust'),
  corruptionPressure('Corruption pressure');

  const CityIndicator(this.label);

  final String label;
}

String indicatorState(int value) => switch (value) {
  <= 19 => 'Critical',
  <= 39 => 'Poor',
  <= 59 => 'Unstable',
  <= 79 => 'Functional',
  _ => 'Strong',
};
