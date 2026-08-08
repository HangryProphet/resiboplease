import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/domain/models/candidate_name_registry.dart';

void main() {
  test('full names are unique regardless of whitespace or case', () {
    final registry = CandidateNameRegistry(['Maya Vargas']);

    expect(registry.contains('  MAYA   VARGAS '), isTrue);
    expect(registry.reserve('maya vargas'), isFalse);
    expect(registry.reserve('Maya Santos'), isTrue);
    expect(registry.usedNames, hasLength(2));
  });

  test('generation never repeats a full name in one world', () {
    final registry = CandidateNameRegistry();
    final generated = <String>{};

    for (var index = 0; index < 24; index++) {
      generated.add(
        registry.generate(
          firstNames: const ['Ana', 'Ben'],
          surnames: const ['Cruz', 'Reyes'],
          seed: 9000 + index,
          maxAttempts: 8,
        ),
      );
    }

    expect(generated, hasLength(24));
    expect(registry.usedNames, hasLength(24));
  });

  test('seeded candidate identifiers are stable and index-specific', () {
    final first = CandidateNameRegistry.seededCandidateId(seed: 42, index: 0);

    expect(first, CandidateNameRegistry.seededCandidateId(seed: 42, index: 0));
    expect(
      first,
      isNot(CandidateNameRegistry.seededCandidateId(seed: 42, index: 1)),
    );
  });
}
