/// Stable, versioned sub-seed derivation for isolated procedural systems.
///
/// Adding an extra draw to `candidate:0:citybook` cannot change identity,
/// city issues, another candidate, or the term simulation.
abstract final class SeedDerivation {
  static int derive({
    required int worldSeed,
    required int generationVersion,
    required String path,
  }) {
    var hash = 0x811c9dc5;
    final input = '$worldSeed:v$generationVersion:$path';
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    final positive = hash & 0x7fffffff;
    return positive == 0 ? 1 : positive;
  }
}
