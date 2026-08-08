class CandidateNameRegistry {
  CandidateNameRegistry([Iterable<String> usedNames = const []])
    : _usedNames = usedNames.map(_normalize).toSet();

  final Set<String> _usedNames;

  Set<String> get usedNames => Set.unmodifiable(_usedNames);

  bool contains(String fullName) => _usedNames.contains(_normalize(fullName));

  bool reserve(String fullName) {
    final normalized = _normalize(fullName);
    if (normalized.isEmpty || _usedNames.contains(normalized)) return false;
    _usedNames.add(normalized);
    return true;
  }

  String generate({
    required List<String> firstNames,
    required List<String> surnames,
    required int seed,
    int maxAttempts = 128,
  }) {
    if (firstNames.isEmpty || surnames.isEmpty) {
      throw ArgumentError('Candidate name pools cannot be empty.');
    }
    var state = seed & 0x7fffffff;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      state = (1103515245 * state + 12345) & 0x7fffffff;
      final first = firstNames[state % firstNames.length].trim();
      state = (1103515245 * state + 12345) & 0x7fffffff;
      final surname = surnames[state % surnames.length].trim();
      final candidate = '$first $surname'.trim();
      if (reserve(candidate)) return candidate;
    }
    var suffix = 1;
    while (true) {
      final fallback =
          '${firstNames.first.trim()} ${surnames.first.trim()} $suffix';
      if (reserve(fallback)) return fallback;
      suffix++;
    }
  }

  static String seededCandidateId({required int seed, required int index}) {
    final value = ((seed * 31) ^ (index * 2654435761)) & 0xffffffff;
    return 'candidate_${value.toRadixString(16).padLeft(8, '0')}';
  }

  static String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
