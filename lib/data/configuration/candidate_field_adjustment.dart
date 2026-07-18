import '../../domain/models/candidate.dart';
import '../../domain/models/city_run_configuration.dart';
import '../../domain/simulation/seeded_random.dart';

/// Hidden, simulation-facing changes produced by the candidate-field setting.
///
/// The adjustment deliberately contains both an advantage and a friction. A
/// seasoned field is stronger on average, but no candidate receives a blanket
/// upgrade; an unproven field is less reliable on average, but each candidate
/// retains one area of promise. The values are deterministic for a run seed.
class CandidateFieldAdjustment {
  const CandidateFieldAdjustment({
    required this.implementation,
    required this.coalition,
    required this.crisis,
    required this.budget,
  });

  const CandidateFieldAdjustment.none()
    : implementation = 0,
      coalition = 0,
      crisis = 0,
      budget = 0;

  final int implementation;
  final int coalition;
  final int crisis;
  final int budget;

  List<int> get values => [implementation, coalition, crisis, budget];
}

CandidateFieldAdjustment candidateFieldAdjustmentFor({
  required Candidate candidate,
  required CandidateField field,
  required int seed,
}) {
  if (field == CandidateField.mixed) {
    return const CandidateFieldAdjustment.none();
  }

  final random = SeededRandom(
    seed ^ _stableHash(candidate.id) ^ (field.index + 1) * 0x51a5,
  );
  final operatingValues = [
    candidate.capabilities.implementationSkill,
    candidate.capabilities.coalitionSkill,
    candidate.capabilities.crisisResponse,
    candidate.capabilities.budgetDiscipline,
  ];
  final weakestIndex = _indexOfMinimum(operatingValues);
  final strongestIndex = _indexOfMaximum(operatingValues);

  final deltas = switch (field) {
    CandidateField.seasoned => List<int>.generate(
      operatingValues.length,
      (index) => index == weakestIndex
          // Experience can harden an old limitation instead of erasing it.
          ? -(3 + random.nextInt(4))
          : 5 + random.nextInt(5),
      growable: false,
    ),
    CandidateField.unproven => List<int>.generate(
      operatingValues.length,
      (index) => index == strongestIndex
          // A less tested candidate can still bring one credible capability.
          ? 2 + random.nextInt(4)
          : -(5 + random.nextInt(6)),
      growable: false,
    ),
    CandidateField.mixed => throw StateError('Handled above.'),
  };

  return CandidateFieldAdjustment(
    implementation: deltas[0],
    coalition: deltas[1],
    crisis: deltas[2],
    budget: deltas[3],
  );
}

int _indexOfMinimum(List<int> values) {
  var result = 0;
  for (var index = 1; index < values.length; index++) {
    if (values[index] < values[result]) result = index;
  }
  return result;
}

int _indexOfMaximum(List<int> values) {
  var result = 0;
  for (var index = 1; index < values.length; index++) {
    if (values[index] > values[result]) result = index;
  }
  return result;
}

int _stableHash(String value) => value.codeUnits.fold(
  0,
  (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
);
