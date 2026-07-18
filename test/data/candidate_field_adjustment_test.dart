import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/configuration/candidate_field_adjustment.dart';
import 'package:resiboplease/data/configuration/configured_scenario.dart';
import 'package:resiboplease/data/seed_content/bayhaven_scenario.dart';
import 'package:resiboplease/domain/models/candidate.dart';
import 'package:resiboplease/domain/models/city_run_configuration.dart';
import 'package:resiboplease/domain/models/scenario.dart';
import 'package:resiboplease/domain/simulation/candidate_tradeoff_audit.dart';

void main() {
  group('candidate field adjustments', () {
    test('are deterministic for the same seed', () {
      final candidate = buildBayhavenScenario().candidates.first;

      final first = candidateFieldAdjustmentFor(
        candidate: candidate,
        field: CandidateField.seasoned,
        seed: 41717,
      );
      final second = candidateFieldAdjustmentFor(
        candidate: candidate,
        field: CandidateField.seasoned,
        seed: 41717,
      );

      expect(second.values, first.values);
    });

    test('vary with the seed without becoming a blanket upgrade', () {
      final candidate = buildBayhavenScenario().candidates.first;
      final seen = <String>{};

      for (final seed in [17, 42, 41717, 5839201]) {
        final adjustment = candidateFieldAdjustmentFor(
          candidate: candidate,
          field: CandidateField.seasoned,
          seed: seed,
        );
        seen.add(adjustment.values.join(','));
        expect(adjustment.values, contains(isNegative));
        expect(adjustment.values, contains(isPositive));
      }

      expect(seen.length, greaterThan(1));
    });

    test('unproven fields retain promise but are weaker on average', () {
      final base = buildBayhavenScenario();
      for (final candidate in base.candidates) {
        final adjustment = candidateFieldAdjustmentFor(
          candidate: candidate,
          field: CandidateField.unproven,
          seed: base.seed,
        );
        expect(adjustment.values.where((value) => value > 0), hasLength(1));
        expect(adjustment.values.reduce((a, b) => a + b), isNegative);
      }
    });

    test(
      'configured fields remain balanced while changing capability truth',
      () {
        final base = buildBayhavenScenario();
        final mixed = _configured(base, CandidateField.mixed);
        final seasoned = _configured(base, CandidateField.seasoned);
        final unproven = _configured(base, CandidateField.unproven);

        expect(
          _operatingTotal(seasoned.candidates),
          greaterThan(_operatingTotal(mixed.candidates)),
        );
        expect(
          _operatingTotal(unproven.candidates),
          lessThan(_operatingTotal(mixed.candidates)),
        );

        for (final scenario in [unproven, mixed, seasoned]) {
          for (final candidate in scenario.candidates) {
            final audit = auditCandidateTradeoffs(candidate);
            expect(
              audit.passes,
              isTrue,
              reason: '${candidate.id}: ${audit.violations.join(', ')}',
            );
            expect(audit.visibleStrengthCount, greaterThanOrEqualTo(2));
            expect(audit.visibleConcernCount, greaterThanOrEqualTo(2));
            expect(audit.hiddenStrengthCount, greaterThanOrEqualTo(2));
            expect(audit.hiddenLiabilityCount, greaterThanOrEqualTo(2));
            expect(audit.uncertaintyCount, greaterThanOrEqualTo(1));
          }
        }
      },
    );
  });
}

Scenario _configured(Scenario base, CandidateField field) =>
    buildConfiguredScenario(
      base: base,
      configuration: CityRunConfiguration.defaults().copyWith(
        candidateField: field,
      ),
    );

int _operatingTotal(List<Candidate> candidates) => candidates.fold(
  0,
  (total, candidate) =>
      total +
      candidate.capabilities.implementationSkill +
      candidate.capabilities.coalitionSkill +
      candidate.capabilities.crisisResponse +
      candidate.capabilities.budgetDiscipline,
);
