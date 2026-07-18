import 'city_indicator.dart';

enum StartingPressure {
  stable(
    'Stable',
    'Services are holding, but important weaknesses still need attention.',
  ),
  strained(
    'Strained',
    'Several systems are under pressure and difficult choices are already due.',
  ),
  crisis(
    'Crisis',
    'The city begins with severe problems, low breathing room, and urgent risks.',
  );

  const StartingPressure(this.label, this.description);

  final String label;
  final String description;
}

enum CityConcern {
  food('Food security', 'Food prices and access', CityIndicator.foodSecurity),
  poverty('Poverty', 'Families falling behind', CityIndicator.povertyReduction),
  health(
    'Public health',
    'Clinics and community care',
    CityIndicator.publicHealth,
  ),
  education(
    'Education',
    'Schools and learning access',
    CityIndicator.educationQuality,
  ),
  water('Water', 'Safe and reliable water', CityIndicator.waterSecurity),
  jobs(
    'Jobs',
    'Employment and working conditions',
    CityIndicator.employmentQuality,
  ),
  cityServices(
    'Housing & transport',
    'Neighborhood and infrastructure strain',
    CityIndicator.urbanResilience,
  ),
  climate(
    'Climate',
    'Flood, heat, and disaster readiness',
    CityIndicator.climateResilience,
  );

  const CityConcern(this.label, this.description, this.indicator);

  final String label;
  final String description;
  final CityIndicator indicator;
}

enum CandidateField {
  unproven(
    'Unproven',
    'Candidates have less governing experience and more uncertain delivery.',
  ),
  mixed(
    'Mixed',
    'The field contains a broad mix of experience and operating skill.',
  ),
  seasoned(
    'Seasoned',
    'Candidates are generally more experienced, but still carry real tradeoffs.',
  );

  const CandidateField(this.label, this.description);

  final String label;
  final String description;
}

enum AssistanceMode {
  guided(
    'Guided',
    'Resi introduces new screens and offers neutral civic-learning reminders.',
  ),
  standard(
    'Standard',
    'No automatic guidance. The Guide button remains available whenever needed.',
  );

  const AssistanceMode(this.label, this.description);

  final String label;
  final String description;
}

enum CampaignNoise {
  clear(
    'Clear',
    'Official records and accountable sources are easier to find first.',
  ),
  typical(
    'Typical',
    'Campaign material, records, posts, and fact-checks arrive in a normal mix.',
  ),
  noisy(
    'Noisy',
    'Extra rumors and attention-grabbing posts compete with stronger evidence.',
  );

  const CampaignNoise(this.label, this.description);

  final String label;
  final String description;
}

enum InvestigationTime {
  relaxed('Relaxed', 'Open as many evidence files as you want.', null),
  standard(
    'Standard',
    'You have 12 investigation points. Candidate profiles are free.',
    12,
  ),
  limited(
    'Limited',
    'You have 7 investigation points. Candidate profiles are free.',
    7,
  );

  const InvestigationTime(this.label, this.description, this.pointLimit);

  final String label;
  final String description;
  final int? pointLimit;
}

class CityRunConfiguration {
  const CityRunConfiguration({
    required this.cityName,
    required this.startingPressure,
    required this.mainConcerns,
    required this.candidateField,
    required this.assistanceMode,
    required this.campaignNoise,
    required this.investigationTime,
  }) : assert(mainConcerns.length >= 1 && mainConcerns.length <= 3);

  factory CityRunConfiguration.defaults({String cityName = 'New City'}) =>
      CityRunConfiguration(
        cityName: cityName,
        startingPressure: StartingPressure.strained,
        mainConcerns: const [
          CityConcern.water,
          CityConcern.jobs,
          CityConcern.health,
        ],
        candidateField: CandidateField.mixed,
        assistanceMode: AssistanceMode.guided,
        campaignNoise: CampaignNoise.typical,
        investigationTime: InvestigationTime.standard,
      );

  final String cityName;
  final StartingPressure startingPressure;
  final List<CityConcern> mainConcerns;
  final CandidateField candidateField;
  final AssistanceMode assistanceMode;
  final CampaignNoise campaignNoise;
  final InvestigationTime investigationTime;

  CityRunConfiguration copyWith({
    String? cityName,
    StartingPressure? startingPressure,
    List<CityConcern>? mainConcerns,
    CandidateField? candidateField,
    AssistanceMode? assistanceMode,
    CampaignNoise? campaignNoise,
    InvestigationTime? investigationTime,
  }) => CityRunConfiguration(
    cityName: cityName ?? this.cityName,
    startingPressure: startingPressure ?? this.startingPressure,
    mainConcerns: mainConcerns ?? this.mainConcerns,
    candidateField: candidateField ?? this.candidateField,
    assistanceMode: assistanceMode ?? this.assistanceMode,
    campaignNoise: campaignNoise ?? this.campaignNoise,
    investigationTime: investigationTime ?? this.investigationTime,
  );
}
