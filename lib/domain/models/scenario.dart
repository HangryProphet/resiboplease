import 'candidate.dart';
import 'city.dart';

class Scenario {
  const Scenario({
    required this.id,
    required this.seed,
    required this.city,
    required this.candidates,
  });

  final String id;
  final int seed;
  final City city;
  final List<Candidate> candidates;

  Scenario copyWith({
    String? id,
    int? seed,
    City? city,
    List<Candidate>? candidates,
  }) => Scenario(
    id: id ?? this.id,
    seed: seed ?? this.seed,
    city: city ?? this.city,
    candidates: candidates ?? this.candidates,
  );
}
