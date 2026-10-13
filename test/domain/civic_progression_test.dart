import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/core/settings/app_settings_controller.dart';
import 'package:resiboplease/core/state/game_controller.dart';
import 'package:resiboplease/domain/models/citizen_action.dart';
import 'package:resiboplease/domain/models/civic_progression.dart';

void main() {
  test(
    'civic tracks are derived from unique activity without duplicate farming',
    () {
      final profile = CivicProgressionProfile.fromState(
        administrations: const [],
        activeViewedEvidenceIds: {
          'e1',
          'e2',
          'e3',
          'e4',
          'e5',
          'e6',
          'e7',
          'e8',
        },
        activeBookmarkedEvidenceIds: const {},
        activeReceiptNotes: const {},
      );

      final research = profile.progressFor(CivicProgressionTrack.research);
      expect(research.points, 8);
      expect(research.level, 2);
      expect(research.fractionToNextLevel, 0);
      expect(profile.evidenceOrganizerUnlocked, isTrue);
      expect(
        profile.accomplishments
            .singleWhere((item) => item.id == 'multi_source_investigator')
            .achieved,
        isTrue,
      );
    },
  );

  test('source organizer stays locked before research level two', () {
    final profile = CivicProgressionProfile.fromState(
      administrations: const [],
      activeViewedEvidenceIds: const {'e1', 'e2', 'e3'},
      activeBookmarkedEvidenceIds: const {'e1'},
      activeReceiptNotes: const {},
    );

    expect(profile.progressFor(CivicProgressionTrack.research).level, 1);
    expect(profile.evidenceOrganizerUnlocked, isFalse);
  });

  test(
    'accountability and organizing ranks grant only bounded time savings',
    () {
      final accountability = CivicProgressionProfile.fromState(
        administrations: const [],
        activeViewedEvidenceIds: const {},
        activeBookmarkedEvidenceIds: const {},
        activeReceiptNotes: {
          'n1': 'a',
          'n2': 'b',
          'n3': 'c',
          'n4': 'd',
          'n5': 'e',
          'n6': 'f',
          'n7': 'g',
          'n8': 'h',
        },
      );

      expect(
        accountability.actionDelayReductionDays(
          CitizenActionType.requestPublicRecords,
        ),
        3,
      );
      expect(
        accountability.actionDelayReductionDays(
          CitizenActionType.organizePetition,
        ),
        0,
      );
    },
  );

  test('completed administration creates durable civic milestones', () {
    final controller = GameController(activeRun: true);
    addTearDown(controller.dispose);
    controller.castVote(
      candidate: controller.scenario.candidates.first,
      topIssue: controller.scenario.city.problems.first.id,
      confidence: .7,
    );
    controller.fastForwardToYearEnd(
      interruptionPreference: CriticalEventInterruption.neverInterrupt,
    );
    controller.continueToNextElection();

    final profile = controller.civicProgression;
    expect(
      profile.accomplishments
          .singleWhere((item) => item.id == 'first_administration')
          .achieved,
      isTrue,
    );
    expect(
      profile.progressFor(CivicProgressionTrack.historicalAnalysis).points,
      5,
    );
    expect(profile.accomplishedCount, greaterThanOrEqualTo(1));
  });
}
