import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/domain/models/public_city_snapshot.dart';

void main() {
  test('completed term builds a sanitized public snapshot only', () {
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    final candidate = controller.scenario.candidates.first;
    final issue = controller.scenario.city.problems.first;
    controller.castVote(
      candidate: candidate,
      topIssue: issue.id,
      confidence: .8,
    );

    final snapshot = buildPublicCitySnapshot(
      city: controller.scenario.city,
      configuration: controller.activeConfiguration!,
      result: controller.termResult!,
      topIssueId: controller.topIssue,
      createdAt: DateTime.utc(2026, 8, 18, 9, 30),
    );
    final json = snapshot.toPublishJson();

    expect(snapshot.cityName, controller.activeCityName);
    expect(snapshot.selectedCandidateName, candidate.name);
    expect(snapshot.candidateParty, candidate.party);
    expect(snapshot.topIssue, issue.title);
    expect(snapshot.majorIssues, hasLength(3));
    expect(snapshot.majorEvents, isNotEmpty);
    expect(
      snapshot.finalCityCondition,
      isIn(['strong', 'functional', 'mixed', 'strained', 'critical']),
    );
    expect(json, isNot(contains('seed')));
    expect(json, isNot(contains('capabilities')));
    expect(json, isNot(contains('investigation_history')));
    expect(json, isNot(contains('configuration')));
    expect(json.keys, hasLength(12));
    expect(json['is_public'], isTrue);
    expect(json, isNot(contains('owner_id')));
  });

  test('snapshot JSON round-trips the public API fields', () {
    final source = sampleSnapshot(id: 'snapshot-1');
    final restored = PublicCitySnapshot.fromJson(source.toJson());

    expect(restored.id, 'snapshot-1');
    expect(restored.ownerDisplayName, 'Kazuma');
    expect(restored.cityName, 'Harborlight');
    expect(restored.majorIssues, ['Water access', 'Transport']);
    expect(restored.createdAt, DateTime.utc(2026, 8, 18));
  });
}

PublicCitySnapshot sampleSnapshot({String? id = 'snapshot-1'}) =>
    PublicCitySnapshot(
      id: id,
      ownerId: '00000000-0000-4000-8000-000000000001',
      ownerDisplayName: 'Kazuma',
      cityName: 'Harborlight',
      termNumber: 1,
      startingPressure: 'strained',
      topIssue: 'Water access',
      selectedCandidateName: 'Maya Vargas',
      candidateParty: 'Bayhaven Civic Alliance',
      finalCityCondition: 'mixed',
      outcomeSummary:
          'Public health improved while transport remained under pressure.',
      majorIssues: const ['Water access', 'Transport'],
      majorEvents: const ['Clinic response', 'Water emergency'],
      createdAt: DateTime.utc(2026, 8, 18),
    );
