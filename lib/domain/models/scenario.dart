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
}
