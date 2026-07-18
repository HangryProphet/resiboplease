import 'city_indicator.dart';

class CityIndicatorSet {
  const CityIndicatorSet({
    required this.foodSecurity,
    required this.povertyReduction,
    required this.publicHealth,
    required this.educationQuality,
    required this.waterSecurity,
    required this.employmentQuality,
    required this.urbanResilience,
    required this.climateResilience,
    required this.budgetHealth,
    required this.publicTrust,
    required this.corruptionPressure,
  });

  final int foodSecurity;
  final int povertyReduction;
  final int publicHealth;
  final int educationQuality;
  final int waterSecurity;
  final int employmentQuality;
  final int urbanResilience;
  final int climateResilience;
  final int budgetHealth;
  final int publicTrust;
  final int corruptionPressure;

  factory CityIndicatorSet.fromJson(Map<String, Object?> json) {
    int read(CityIndicator indicator) {
      final value = json[indicator.name];
      if (value is! num) {
        throw FormatException('Missing city indicator ${indicator.name}.');
      }
      return value.toInt().clamp(0, 100);
    }

    return CityIndicatorSet(
      foodSecurity: read(CityIndicator.foodSecurity),
      povertyReduction: read(CityIndicator.povertyReduction),
      publicHealth: read(CityIndicator.publicHealth),
      educationQuality: read(CityIndicator.educationQuality),
      waterSecurity: read(CityIndicator.waterSecurity),
      employmentQuality: read(CityIndicator.employmentQuality),
      urbanResilience: read(CityIndicator.urbanResilience),
      climateResilience: read(CityIndicator.climateResilience),
      budgetHealth: read(CityIndicator.budgetHealth),
      publicTrust: read(CityIndicator.publicTrust),
      corruptionPressure: read(CityIndicator.corruptionPressure),
    );
  }

  int valueOf(CityIndicator indicator) => switch (indicator) {
    CityIndicator.foodSecurity => foodSecurity,
    CityIndicator.povertyReduction => povertyReduction,
    CityIndicator.publicHealth => publicHealth,
    CityIndicator.educationQuality => educationQuality,
    CityIndicator.waterSecurity => waterSecurity,
    CityIndicator.employmentQuality => employmentQuality,
    CityIndicator.urbanResilience => urbanResilience,
    CityIndicator.climateResilience => climateResilience,
    CityIndicator.budgetHealth => budgetHealth,
    CityIndicator.publicTrust => publicTrust,
    CityIndicator.corruptionPressure => corruptionPressure,
  };

  Map<CityIndicator, int> get values => {
    for (final indicator in CityIndicator.values) indicator: valueOf(indicator),
  };

  CityIndicatorSet apply(Map<CityIndicator, int> changes) {
    int updated(CityIndicator indicator) =>
        (valueOf(indicator) + (changes[indicator] ?? 0)).clamp(0, 100);

    return CityIndicatorSet(
      foodSecurity: updated(CityIndicator.foodSecurity),
      povertyReduction: updated(CityIndicator.povertyReduction),
      publicHealth: updated(CityIndicator.publicHealth),
      educationQuality: updated(CityIndicator.educationQuality),
      waterSecurity: updated(CityIndicator.waterSecurity),
      employmentQuality: updated(CityIndicator.employmentQuality),
      urbanResilience: updated(CityIndicator.urbanResilience),
      climateResilience: updated(CityIndicator.climateResilience),
      budgetHealth: updated(CityIndicator.budgetHealth),
      publicTrust: updated(CityIndicator.publicTrust),
      corruptionPressure: updated(CityIndicator.corruptionPressure),
    );
  }

  Map<String, Object?> toJson() => {
    for (final entry in values.entries) entry.key.name: entry.value,
  };

  @override
  bool operator ==(Object other) =>
      other is CityIndicatorSet && _sameValues(other);

  bool _sameValues(CityIndicatorSet other) {
    for (final indicator in CityIndicator.values) {
      if (valueOf(indicator) != other.valueOf(indicator)) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(values.values);
}
