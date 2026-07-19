import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/persistence/run_save_data.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';

void main() {
  RunSaveData sampleRun() {
    final scenario = buildBayhavenScenario(seed: 42);
    return RunSaveData(
      seed: scenario.seed,
      configuration: CityRunConfiguration.defaults(cityName: 'Harborlight'),
      indicators: scenario.city.indicators,
      term: 2,
      bookmarkedEvidenceIds: {'maya_factCheck'},
      viewedEvidenceIds: {'maya_profile', 'maya_factCheck'},
      chargedEvidenceIds: {'maya_factCheck'},
      selectedCandidateId: 'maya_vargas',
      termResultReady: true,
      revealedTermPhases: 4,
      topIssue: 'water_contamination',
      confidence: .8,
      createdAt: DateTime.utc(2026, 7, 18),
      updatedAt: DateTime.utc(2026, 7, 19),
    );
  }

  test('versioned save data survives a JSON-safe round trip', () {
    final original = GameSaveData(
      activeSlotIndex: 2,
      slots: [null, null, sampleRun(), null, null],
      updatedAt: DateTime.utc(2026, 7, 20),
    );

    final restored = GameSaveData.fromJson(original.toJson());
    final run = restored.slots[2]!;

    expect(restored.activeSlotIndex, 2);
    expect(restored.updatedAt, DateTime.utc(2026, 7, 20));
    expect(run.configuration.cityName, 'Harborlight');
    expect(run.seed, 42);
    expect(run.term, 2);
    expect(run.selectedCandidateId, 'maya_vargas');
    expect(run.termResultReady, isTrue);
    expect(run.revealedTermPhases, 4);
    expect(run.viewedEvidenceIds, {'maya_profile', 'maya_factCheck'});
    expect(run.indicators, buildBayhavenScenario(seed: 42).city.indicators);
  });

  test('schema zero active-slot data migrates to the current schema', () {
    final raw = GameSaveData(activeSlotIndex: 0, slots: [sampleRun()]).toJson();
    raw.remove('schema_version');
    raw['active_slot'] = raw.remove('active_slot_index');

    final restored = GameSaveData.fromJson(raw);

    expect(restored.activeSlotIndex, 0);
    expect(restored.slots.single!.configuration.cityName, 'Harborlight');
  });

  test('future save schemas are rejected instead of silently discarded', () {
    final raw = GameSaveData(activeSlotIndex: null, slots: const []).toJson()
      ..['schema_version'] = 99;

    expect(() => GameSaveData.fromJson(raw), throwsUnsupportedError);
  });
}
