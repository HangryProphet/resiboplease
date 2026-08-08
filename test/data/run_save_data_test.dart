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
      evidencePointCosts: {'maya_factCheck': 1},
      unlockedEvidenceIds: {'maya_budgetDocument'},
      pinnedCandidateIds: {'maya_vargas'},
      pinnedContentIds: {'pulse_maya_promise'},
      pinnedQuestionIds: {'question_maya_donors'},
      bookmarkedDebateMessageIds: {'dw03'},
      pinnedDebateMessageIds: {'dw04'},
      suspiciousDebateMessageIds: {'dw07'},
      receiptNotes: {'content:pulse_maya_promise': 'Check the funding.'},
      usedCandidateNames: {'Maya Vargas', 'Julian Pratt', 'Victor Chen'},
      chronicleStoryIds: ['brief_water', 'brief_flavor_market_0'],
      chronicleVoiceIds: ['voice_water_0'],
      usedChronicleTemplateIds: {'issue_waterSupply_0', 'flavor_market_0'},
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
    expect(run.evidencePointCosts, {'maya_factCheck': 1});
    expect(run.unlockedEvidenceIds, {'maya_budgetDocument'});
    expect(run.pinnedCandidateIds, {'maya_vargas'});
    expect(run.pinnedContentIds, {'pulse_maya_promise'});
    expect(run.pinnedQuestionIds, {'question_maya_donors'});
    expect(run.bookmarkedDebateMessageIds, {'dw03'});
    expect(run.pinnedDebateMessageIds, {'dw04'});
    expect(run.suspiciousDebateMessageIds, {'dw07'});
    expect(run.receiptNotes, {
      'content:pulse_maya_promise': 'Check the funding.',
    });
    expect(
      run.usedCandidateNames,
      containsAll(['Maya Vargas', 'Julian Pratt', 'Victor Chen']),
    );
    expect(run.chronicleStoryIds, ['brief_water', 'brief_flavor_market_0']);
    expect(run.chronicleVoiceIds, ['voice_water_0']);
    expect(run.usedChronicleTemplateIds, {
      'issue_waterSupply_0',
      'flavor_market_0',
    });
    expect(run.indicators, buildBayhavenScenario(seed: 42).city.indicators);
  });

  test('schema zero active-slot data migrates to the current schema', () {
    final raw = GameSaveData(activeSlotIndex: 0, slots: [sampleRun()]).toJson();
    raw.remove('schema_version');
    raw['active_slot'] = raw.remove('active_slot_index');

    final restored = GameSaveData.fromJson(raw);

    expect(restored.activeSlotIndex, 0);
    expect(restored.slots.single!.configuration.cityName, 'Harborlight');
    expect(restored.slots.single!.evidencePointCosts, {'maya_factCheck': 1});
  });

  test('schema two investigation data migrates to one-point legacy costs', () {
    final raw = GameSaveData(activeSlotIndex: 0, slots: [sampleRun()]).toJson()
      ..['schema_version'] = 2;
    final slot = (raw['slots']! as List).single! as Map<String, Object?>;
    for (final key in const [
      'evidence_point_costs',
      'unlocked_evidence_ids',
      'pinned_candidate_ids',
      'pinned_content_ids',
      'pinned_question_ids',
      'bookmarked_debate_message_ids',
      'pinned_debate_message_ids',
      'suspicious_debate_message_ids',
      'receipt_notes',
      'used_candidate_names',
    ]) {
      slot.remove(key);
    }

    final restored = GameSaveData.fromJson(raw).slots.single!;

    expect(restored.evidencePointCosts, {'maya_factCheck': 1});
    expect(restored.pinnedContentIds, isEmpty);
    expect(restored.pinnedQuestionIds, isEmpty);
    expect(restored.receiptNotes, isEmpty);
  });

  test('future save schemas are rejected instead of silently discarded', () {
    final raw = GameSaveData(activeSlotIndex: null, slots: const []).toJson()
      ..['schema_version'] = 99;

    expect(() => GameSaveData.fromJson(raw), throwsUnsupportedError);
  });

  test('schema four saves gain empty Chronicle persistence fields', () {
    final raw = GameSaveData(activeSlotIndex: 0, slots: [sampleRun()]).toJson()
      ..['schema_version'] = 4;
    final slot = (raw['slots']! as List).single! as Map<String, Object?>;
    slot.remove('chronicle_story_ids');
    slot.remove('chronicle_voice_ids');
    slot.remove('used_chronicle_template_ids');

    final restored = GameSaveData.fromJson(raw).slots.single!;

    expect(restored.chronicleStoryIds, isEmpty);
    expect(restored.chronicleVoiceIds, isEmpty);
    expect(restored.usedChronicleTemplateIds, isEmpty);
  });
}
