import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/domain/models/player_profile.dart';

void main() {
  test('display names are trimmed, space-normalized, and case-normalized', () {
    expect(validatePlayerDisplayName('  Kazuma   Player  '), 'Kazuma Player');
    expect(normalizePlayerDisplayName('Kazuma Player'), 'kazuma player');
  });

  test('display names reject short, long, and control/symbol input', () {
    expect(() => validatePlayerDisplayName('ab'), throwsFormatException);
    expect(() => validatePlayerDisplayName('a' * 25), throwsFormatException);
    expect(
      () => validatePlayerDisplayName('Kazuma<script>'),
      throwsFormatException,
    );
    expect(
      () => validatePlayerDisplayName('Kazuma\nAdmin'),
      throwsFormatException,
    );
  });
}
