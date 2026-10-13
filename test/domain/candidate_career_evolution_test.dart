import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/simulation/candidate_career_evolution_engine.dart';

void main() {
  test('career evolution is bounded, causal, and deterministic', () {
    final controller = GameController();
    addTearDown(controller.dispose);
    controller.createCity(
      slotIndex: 0,
      configuration: CityRunConfiguration.defaults(
        cityName: 'Career Record City',
      ),
      worldSeed: 440022,
    );
    final mayor = controller.scenario.candidates.first;
    final baseline = controller.candidateExperience;
    controller.castVote(
      candidate: mayor,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .68,
    );
    while (!controller.isTermReportReady) {
      controller.advanceTerm();
    }
    controller.continueToNextElection();

    final record = controller.administrationHistory.single;
    final originalTruth = record.election!.truthProfiles[mayor.id]!;
    const engine = CandidateCareerEvolutionEngine();
    final first = engine.evolve(
      baseline: originalTruth,
      administration: record.livingCity,
    );
    final second = engine.evolve(
      baseline: originalTruth,
      administration: record.livingCity,
    );

    expect(first.attributeDeltas, second.attributeDeltas);
    expect(first.publicReasons, second.publicReasons);
    expect(first.publicReasons, isNotEmpty);
    expect(first.truth.qualityBand, originalTruth.qualityBand);
    expect(first.truth.careerOrigin, originalTruth.careerOrigin);
    expect(first.truth.motivations, originalTruth.motivations);
    expect(first.truth.hiddenRisks, originalTruth.hiddenRisks);
    expect(first.truth.relationships, originalTruth.relationships);
    final hasNewProcurementScrutiny = record.livingCity.eventHistory.any(
      (event) =>
          event.templateId == 'procurement_questions' ||
          event.templateId == 'anonymous_documents',
    );
    if (hasNewProcurementScrutiny) {
      expect(
        first.truth.controversies.length,
        originalTruth.controversies.length + 1,
      );
      expect(
        first.truth.controversies.last.id,
        'administration_${record.termNumber}_procurement_scrutiny',
      );
    } else {
      expect(first.truth.controversies, originalTruth.controversies);
    }
    expect(first.attributeDeltas['experience'], inInclusiveRange(3, 6));
    expect(first.attributeDeltas['politicalFatigue'], inInclusiveRange(1, 9));
    expect(
      first.truth.politicalFatigue,
      greaterThan(originalTruth.politicalFatigue),
    );
    for (final value in [
      first.truth.generalCompetence,
      first.truth.implementationSkill,
      first.truth.integrity,
      first.truth.corruptionRisk,
      first.truth.coalitionSkill,
      first.truth.communication,
      first.truth.budgetDiscipline,
      first.truth.crisisResponse,
      first.truth.adaptability,
      first.truth.experience,
      first.truth.reformCredibility,
      first.truth.politicalFatigue,
      first.truth.institutionalStanding,
      ...first.truth.policyScores.values,
    ]) {
      expect(value, inInclusiveRange(5, 95));
    }

    final returningMayor = controller.candidateById(mayor.id);
    expect(
      returningMayor.capabilities.implementationSkill,
      first.truth.implementationSkill,
    );
    expect(returningMayor.capabilities.integrity, first.truth.integrity);
    expect(
      returningMayor.capabilities.corruptionRisk,
      first.truth.corruptionRisk,
    );
    expect(
      returningMayor.evidence
          .firstWhere((item) => item.id.endsWith('public_record'))
          .details,
      contains('direct governing experience'),
    );

    // The previous generated catalog remains a separate immutable snapshot.
    expect(record.election!.candidateExperience.profiles, baseline.profiles);
  });
}
