import '../../domain/models/candidate.dart';
import '../../domain/models/city.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_indicator_set.dart';
import '../../domain/models/city_problem.dart';
import '../../domain/models/evidence_item.dart';
import '../../domain/models/scenario.dart';

Scenario buildBayhavenScenario({int seed = 5839201}) => Scenario(
  id: 'bayhaven_first_election',
  seed: seed,
  city: const City(
    name: 'Bayhaven',
    summary:
        'Two flood seasons exposed brittle water lines, crowded clinics, and an economy that has not recovered evenly.',
    term: 1,
    indicators: CityIndicatorSet(
      foodSecurity: 58,
      povertyReduction: 46,
      publicHealth: 41,
      educationQuality: 62,
      waterSecurity: 35,
      employmentQuality: 39,
      urbanResilience: 44,
      climateResilience: 32,
      budgetHealth: 60,
      publicTrust: 48,
      corruptionPressure: 42,
    ),
    problems: [
      CityProblem(
        id: 'water_contamination',
        title: 'Post-flood water contamination',
        description:
            'Three districts report unsafe tap water after heavy rain overwhelms damaged lines.',
        primaryIndicator: CityIndicator.waterSecurity,
        relatedIndicators: [
          CityIndicator.publicHealth,
          CityIndicator.climateResilience,
        ],
        severity: 84,
        urgency: 90,
        trend: ProblemTrend.rapidlyWorsening,
        sdgTags: ['SDG 6', 'SDG 3', 'SDG 13'],
      ),
      CityProblem(
        id: 'unemployment',
        title: 'Rising unemployment',
        description:
            'Small manufacturers are closing while new jobs remain short-term and low-paid.',
        primaryIndicator: CityIndicator.employmentQuality,
        relatedIndicators: [
          CityIndicator.povertyReduction,
          CityIndicator.foodSecurity,
        ],
        severity: 76,
        urgency: 78,
        trend: ProblemTrend.worsening,
        sdgTags: ['SDG 8', 'SDG 1'],
      ),
      CityProblem(
        id: 'clinic_overload',
        title: 'Overcrowded public clinics',
        description:
            'Patients wait most of a day as neighborhood clinics share too few staff and supplies.',
        primaryIndicator: CityIndicator.publicHealth,
        relatedIndicators: [CityIndicator.povertyReduction],
        severity: 79,
        urgency: 86,
        trend: ProblemTrend.worsening,
        sdgTags: ['SDG 3', 'SDG 1'],
      ),
    ],
  ),
  candidates: [_maya, _julian, _victor],
);

final Candidate _maya = Candidate(
  id: 'maya_vargas',
  name: 'Maya Vargas',
  party: 'Kalinga Civic Alliance',
  archetype: 'Popular reformer',
  slogan: 'Care that reaches every street.',
  biography:
      'A former community-health director who built mobile clinic partnerships across Bayhaven. Her coalition is young and energetic, but several large donors have interests in medical supply contracts.',
  visibleStrengths: const [
    'Deep public-health experience',
    'Clear crisis communication',
  ],
  visibleConcerns: const [
    'Funding plan relies on optimistic revenue',
    'Major campaign donors may create pressure',
  ],
  platform: const [
    'Extend clinic hours and mobile care',
    'Create paid public-health apprenticeships',
    'Replace the highest-risk water lines',
  ],
  evidence: _evidenceFor(
    prefix: 'maya',
    name: 'Maya Vargas',
    publicRecord:
        'Clinic wait times fell in two pilot districts, although the program used a one-time grant.',
    budget:
        'The first-year plan leaves a funding gap if projected business taxes arrive late.',
    socialClaim:
        'A viral post says Vargas personally built twelve clinics. Records show she coordinated two mobile units.',
    factCheck:
        'Her access claims are broadly supported; the construction claim circulating online is misleading.',
    controversy:
        'A medical distributor supporting her campaign could bid on city contracts. No improper award is documented.',
    debate:
        'Vargas prioritizes clinic staffing first and proposes phased water repairs, but gives few details on long-term maintenance.',
  ),
  capabilities: const CandidateCapabilities(
    policyScores: {
      CityIndicator.publicHealth: 88,
      CityIndicator.waterSecurity: 65,
      CityIndicator.employmentQuality: 62,
      CityIndicator.climateResilience: 57,
      CityIndicator.povertyReduction: 72,
    },
    implementationSkill: 69,
    integrity: 66,
    coalitionSkill: 74,
    crisisResponse: 82,
    budgetDiscipline: 43,
    corruptionRisk: 55,
  ),
  colorValue: 0xFF9B4D72,
);

final Candidate _julian = Candidate(
  id: 'julian_pratt',
  name: 'Julian Pratt',
  party: 'Forward Bayhaven Party',
  archetype: 'Business-backed executive',
  slogan: 'Put Bayhaven back to work.',
  biography:
      'A logistics executive and former development-board chair known for finishing projects quickly. His jobs agenda is detailed, while his record includes opaque subcontracting and little climate planning.',
  visibleStrengths: const [
    'Detailed employment program',
    'Strong project delivery record',
  ],
  visibleConcerns: const [
    'Limited climate and health experience',
    'Procurement transparency questions',
  ],
  platform: const [
    'Offer incentives for local manufacturing',
    'Fast-track a logistics and market district',
    'Use private operators for water upgrades',
  ],
  evidence: _evidenceFor(
    prefix: 'julian',
    name: 'Julian Pratt',
    publicRecord:
        'Pratt delivered two development projects on schedule; job retention after subsidies ended was mixed.',
    budget:
        'The proposal identifies revenue sources but shifts long-term maintenance risk to later budgets.',
    socialClaim:
        'Supporters claim every Pratt project created permanent jobs. Labor filings show many positions were seasonal.',
    factCheck:
        'Project completion claims are accurate, while the permanent-job total lacks context.',
    controversy:
        'A family-linked contractor received subcontracts under a board Pratt chaired. The selection notes were not published.',
    debate:
        'Pratt promises immediate hiring incentives and private water repairs, but avoids a question about flood standards.',
  ),
  capabilities: const CandidateCapabilities(
    policyScores: {
      CityIndicator.publicHealth: 51,
      CityIndicator.waterSecurity: 62,
      CityIndicator.employmentQuality: 91,
      CityIndicator.climateResilience: 34,
      CityIndicator.povertyReduction: 67,
    },
    implementationSkill: 88,
    integrity: 42,
    coalitionSkill: 78,
    crisisResponse: 58,
    budgetDiscipline: 76,
    corruptionRisk: 82,
  ),
  colorValue: 0xFFCC6B32,
);

final Candidate _victor = Candidate(
  id: 'victor_chen',
  name: 'Victor Chen',
  party: 'Common Ground Movement',
  archetype: 'Quiet administrator',
  slogan: 'Repair the systems. Restore the trust.',
  biography:
      'A civil engineer and former water authority planner with a reputation for careful audits. His plans are technically grounded, though he has little electoral experience and a small council bloc.',
  visibleStrengths: const [
    'Strong water and infrastructure planning',
    'Consistent transparency record',
  ],
  visibleConcerns: const [
    'Limited coalition support',
    'Employment plan may take time to produce jobs',
  ],
  platform: const [
    'Map and replace contaminated water lines',
    'Publish every infrastructure contract',
    'Train residents for long-term repair work',
  ],
  evidence: _evidenceFor(
    prefix: 'victor',
    name: 'Victor Chen',
    publicRecord:
        'Independent audits found accurate project reporting, but two upgrades were delayed by council votes.',
    budget:
        'The plan is fully costed and reserves maintenance funds, with fewer resources for immediate job subsidies.',
    socialClaim:
        'A post calls Chen the author of a failed dam design. He reviewed safety compliance but did not design the dam.',
    factCheck:
        'The dam allegation misstates his role. His water-loss reduction figures match authority records.',
    controversy:
        'Critics cite slow project starts during his tenure; meeting records show repeated coalition delays.',
    debate:
        'Chen gives a detailed repair sequence and audit plan, but struggles to explain how he will secure council votes.',
  ),
  capabilities: const CandidateCapabilities(
    policyScores: {
      CityIndicator.publicHealth: 65,
      CityIndicator.waterSecurity: 92,
      CityIndicator.employmentQuality: 55,
      CityIndicator.climateResilience: 84,
      CityIndicator.povertyReduction: 52,
    },
    implementationSkill: 76,
    integrity: 93,
    coalitionSkill: 42,
    crisisResponse: 72,
    budgetDiscipline: 86,
    corruptionRisk: 16,
  ),
  colorValue: 0xFF397D75,
);

List<EvidenceItem> _evidenceFor({
  required String prefix,
  required String name,
  required String publicRecord,
  required String budget,
  required String socialClaim,
  required String factCheck,
  required String controversy,
  required String debate,
}) => [
  _item(
    prefix,
    EvidenceType.profile,
    '$name: profile',
    'Bayhaven Election Desk',
    'Career, education, and public-service background.',
    'A verified overview assembled from fictional city records.',
    TruthStatus.verifiedTrue,
    88,
  ),
  _item(
    prefix,
    EvidenceType.platform,
    'Three promises for Bayhaven',
    '$name campaign',
    'The campaign presents its priorities for the next term.',
    'Promises describe intent. Funding and delivery still require independent scrutiny.',
    TruthStatus.unverified,
    45,
  ),
  _item(
    prefix,
    EvidenceType.campaignAd,
    'A city ready to move',
    '$name campaign',
    'A polished advertisement frames the candidate as the answer to Bayhaven\'s urgent problems.',
    'The advertisement uses selected success stories and does not discuss tradeoffs.',
    TruthStatus.missingContext,
    32,
  ),
  _item(
    prefix,
    EvidenceType.publicRecord,
    'Performance record',
    'Bayhaven Records Office',
    publicRecord,
    publicRecord,
    TruthStatus.verifiedTrue,
    91,
  ),
  _item(
    prefix,
    EvidenceType.budgetDocument,
    'Independent budget reading',
    'Civic Ledger Institute',
    budget,
    budget,
    TruthStatus.mostlyTrue,
    84,
  ),
  _item(
    prefix,
    EvidenceType.socialPost,
    'Trending claim',
    'HarborTalk user post',
    socialClaim,
    socialClaim,
    TruthStatus.misleading,
    18,
  ),
  _item(
    prefix,
    EvidenceType.factCheck,
    'Claim review',
    'Bayhaven Fact Desk',
    factCheck,
    factCheck,
    TruthStatus.verifiedTrue,
    92,
  ),
  _item(
    prefix,
    EvidenceType.controversy,
    'Unresolved questions',
    'The Bayhaven Beacon',
    controversy,
    controversy,
    TruthStatus.partiallyTrue,
    74,
  ),
  _item(
    prefix,
    EvidenceType.debateAnswer,
    'Mayoral debate response',
    'Bayhaven Public Media',
    debate,
    debate,
    TruthStatus.mostlyTrue,
    78,
  ),
];

EvidenceItem _item(
  String prefix,
  EvidenceType type,
  String title,
  String source,
  String summary,
  String details,
  TruthStatus truthStatus,
  int reliability,
) => EvidenceItem(
  id: '${prefix}_${type.name}',
  type: type,
  title: title,
  source: source,
  summary: summary,
  details: details,
  truthStatus: truthStatus,
  reliability: reliability,
);
