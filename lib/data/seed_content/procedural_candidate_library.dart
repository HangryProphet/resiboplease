import '../../domain/models/candidate_biography.dart';
import '../../domain/models/candidate_experience.dart';
import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_problem.dart';

class CandidateBackgroundTemplate {
  const CandidateBackgroundTemplate({
    required this.id,
    required this.occupation,
    required this.education,
    required this.publicIdentity,
    required this.archetype,
    required this.currentPosition,
    required this.primaryIndicators,
    required this.rhetoricalStyles,
    required this.baseExperience,
    required this.weight,
  });

  final String id;
  final String occupation;
  final List<String> education;
  final String publicIdentity;
  final String archetype;
  final String currentPosition;
  final List<CityIndicator> primaryIndicators;
  final List<CandidateRhetoricalStyle> rhetoricalStyles;
  final int baseExperience;
  final int weight;
}

const proceduralCandidateBackgrounds = <CandidateBackgroundTemplate>[
  CandidateBackgroundTemplate(
    id: 'civil_engineer',
    occupation: 'Civil engineer',
    education: ['BS Civil Engineering', 'Certificate in Urban Resilience'],
    publicIdentity: 'Infrastructure specialist seeking a first mayoral term',
    archetype: 'Technical infrastructure reformer',
    currentPosition: 'Infrastructure consultant',
    primaryIndicators: [
      CityIndicator.waterSecurity,
      CityIndicator.urbanResilience,
      CityIndicator.climateResilience,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.technical,
      CandidateRhetoricalStyle.statisticHeavy,
      CandidateRhetoricalStyle.calm,
    ],
    baseExperience: 58,
    weight: 10,
  ),
  CandidateBackgroundTemplate(
    id: 'doctor',
    occupation: 'Physician',
    education: ['Doctor of Medicine', 'Master of Public Health'],
    publicIdentity: 'Public-health professional entering city politics',
    archetype: 'Health-service advocate',
    currentPosition: 'Community hospital medical director',
    primaryIndicators: [
      CityIndicator.publicHealth,
      CityIndicator.povertyReduction,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.calm,
      CandidateRhetoricalStyle.storyDriven,
      CandidateRhetoricalStyle.conciliatory,
    ],
    baseExperience: 48,
    weight: 9,
  ),
  CandidateBackgroundTemplate(
    id: 'prosecutor',
    occupation: 'Prosecutor',
    education: ['Juris Doctor', 'BA Political Science'],
    publicIdentity: 'Former prosecutor campaigning on accountable government',
    archetype: 'Accountability campaigner',
    currentPosition: 'Private legal practitioner',
    primaryIndicators: [
      CityIndicator.publicTrust,
      CityIndicator.corruptionPressure,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.aggressive,
      CandidateRhetoricalStyle.attackFocused,
      CandidateRhetoricalStyle.statisticHeavy,
    ],
    baseExperience: 61,
    weight: 7,
  ),
  CandidateBackgroundTemplate(
    id: 'teacher',
    occupation: 'Teacher and school administrator',
    education: ['Bachelor of Secondary Education', 'MA Education Leadership'],
    publicIdentity: 'Longtime educator promising neighborhood-first services',
    archetype: 'Community educator',
    currentPosition: 'Public school principal',
    primaryIndicators: [
      CityIndicator.educationQuality,
      CityIndicator.povertyReduction,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.storyDriven,
      CandidateRhetoricalStyle.emotional,
      CandidateRhetoricalStyle.conciliatory,
    ],
    baseExperience: 42,
    weight: 8,
  ),
  CandidateBackgroundTemplate(
    id: 'business_executive',
    occupation: 'Business executive',
    education: ['BS Business Administration', 'Executive Finance Program'],
    publicIdentity: 'Private-sector executive promising faster city delivery',
    archetype: 'Growth-oriented outsider',
    currentPosition: 'Logistics company president',
    primaryIndicators: [
      CityIndicator.employmentQuality,
      CityIndicator.budgetHealth,
      CityIndicator.urbanResilience,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.charismatic,
      CandidateRhetoricalStyle.aggressive,
      CandidateRhetoricalStyle.statisticHeavy,
    ],
    baseExperience: 38,
    weight: 8,
  ),
  CandidateBackgroundTemplate(
    id: 'small_business_owner',
    occupation: 'Small-business owner',
    education: ['BS Entrepreneurship'],
    publicIdentity: 'Neighborhood entrepreneur running as a practical outsider',
    archetype: 'Local enterprise advocate',
    currentPosition: 'Market cooperative manager',
    primaryIndicators: [
      CityIndicator.employmentQuality,
      CityIndicator.foodSecurity,
      CityIndicator.povertyReduction,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.storyDriven,
      CandidateRhetoricalStyle.charismatic,
      CandidateRhetoricalStyle.emotional,
    ],
    baseExperience: 31,
    weight: 9,
  ),
  CandidateBackgroundTemplate(
    id: 'council_member',
    occupation: 'City council member',
    education: ['BA Public Administration'],
    publicIdentity: 'Veteran council member seeking executive authority',
    archetype: 'Career city politician',
    currentPosition: 'City council member',
    primaryIndicators: [
      CityIndicator.publicTrust,
      CityIndicator.budgetHealth,
      CityIndicator.urbanResilience,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.charismatic,
      CandidateRhetoricalStyle.evasive,
      CandidateRhetoricalStyle.conciliatory,
    ],
    baseExperience: 82,
    weight: 11,
  ),
  CandidateBackgroundTemplate(
    id: 'public_administrator',
    occupation: 'Public administrator',
    education: ['BS Public Administration', 'Master in Development Management'],
    publicIdentity: 'Longtime administrator campaigning on reliable services',
    archetype: 'Institutional operator',
    currentPosition: 'Former city department director',
    primaryIndicators: [
      CityIndicator.publicTrust,
      CityIndicator.budgetHealth,
      CityIndicator.urbanResilience,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.technical,
      CandidateRhetoricalStyle.calm,
      CandidateRhetoricalStyle.conciliatory,
    ],
    baseExperience: 76,
    weight: 11,
  ),
  CandidateBackgroundTemplate(
    id: 'community_organizer',
    occupation: 'Community organizer',
    education: ['BA Community Development'],
    publicIdentity: 'Grassroots organizer building a citywide reform coalition',
    archetype: 'Grassroots reform candidate',
    currentPosition: 'Neighborhood coalition coordinator',
    primaryIndicators: [
      CityIndicator.povertyReduction,
      CityIndicator.foodSecurity,
      CityIndicator.publicTrust,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.charismatic,
      CandidateRhetoricalStyle.emotional,
      CandidateRhetoricalStyle.storyDriven,
    ],
    baseExperience: 35,
    weight: 9,
  ),
  CandidateBackgroundTemplate(
    id: 'labor_advocate',
    occupation: 'Labor advocate',
    education: ['BA Economics', 'Certificate in Labor Relations'],
    publicIdentity: 'Worker advocate promising durable jobs and fair contracts',
    archetype: 'Labor coalition candidate',
    currentPosition: 'Labor federation policy officer',
    primaryIndicators: [
      CityIndicator.employmentQuality,
      CityIndicator.povertyReduction,
      CityIndicator.foodSecurity,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.aggressive,
      CandidateRhetoricalStyle.storyDriven,
      CandidateRhetoricalStyle.attackFocused,
    ],
    baseExperience: 46,
    weight: 7,
  ),
  CandidateBackgroundTemplate(
    id: 'environmental_specialist',
    occupation: 'Environmental planner',
    education: ['BS Environmental Science', 'MS Climate Planning'],
    publicIdentity: 'Climate planner focused on long-term city resilience',
    archetype: 'Environmental policy specialist',
    currentPosition: 'Regional resilience adviser',
    primaryIndicators: [
      CityIndicator.climateResilience,
      CityIndicator.waterSecurity,
      CityIndicator.urbanResilience,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.technical,
      CandidateRhetoricalStyle.statisticHeavy,
      CandidateRhetoricalStyle.calm,
    ],
    baseExperience: 52,
    weight: 7,
  ),
  CandidateBackgroundTemplate(
    id: 'accountant',
    occupation: 'Certified public accountant',
    education: ['BS Accountancy', 'Government Audit Certification'],
    publicIdentity: 'Auditor promising disciplined budgets and open records',
    archetype: 'Fiscal accountability specialist',
    currentPosition: 'Independent public-sector auditor',
    primaryIndicators: [
      CityIndicator.budgetHealth,
      CityIndicator.publicTrust,
      CityIndicator.corruptionPressure,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.technical,
      CandidateRhetoricalStyle.calm,
      CandidateRhetoricalStyle.statisticHeavy,
    ],
    baseExperience: 57,
    weight: 7,
  ),
  CandidateBackgroundTemplate(
    id: 'media_personality',
    occupation: 'Media personality',
    education: ['BA Communication'],
    publicIdentity:
        'Popular broadcaster translating attention into a mayoral bid',
    archetype: 'Celebrity outsider',
    currentPosition: 'Television and radio host',
    primaryIndicators: [
      CityIndicator.publicTrust,
      CityIndicator.employmentQuality,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.charismatic,
      CandidateRhetoricalStyle.sarcastic,
      CandidateRhetoricalStyle.attackFocused,
    ],
    baseExperience: 18,
    weight: 5,
  ),
  CandidateBackgroundTemplate(
    id: 'nonprofit_leader',
    occupation: 'Nonprofit director',
    education: ['BA Sociology', 'Master in Social Development'],
    publicIdentity: 'Nonprofit leader campaigning on inclusive public services',
    archetype: 'Social-service reformer',
    currentPosition: 'Citywide nonprofit executive director',
    primaryIndicators: [
      CityIndicator.povertyReduction,
      CityIndicator.publicHealth,
      CityIndicator.educationQuality,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.conciliatory,
      CandidateRhetoricalStyle.storyDriven,
      CandidateRhetoricalStyle.calm,
    ],
    baseExperience: 49,
    weight: 8,
  ),
  CandidateBackgroundTemplate(
    id: 'public_safety_official',
    occupation: 'Public-safety official',
    education: ['BS Criminology', 'Disaster Command Training'],
    publicIdentity: 'Former safety official promising order and rapid response',
    archetype: 'Security-focused administrator',
    currentPosition: 'Retired emergency management chief',
    primaryIndicators: [
      CityIndicator.urbanResilience,
      CityIndicator.climateResilience,
      CityIndicator.publicTrust,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.aggressive,
      CandidateRhetoricalStyle.calm,
      CandidateRhetoricalStyle.attackFocused,
    ],
    baseExperience: 72,
    weight: 6,
  ),
  CandidateBackgroundTemplate(
    id: 'lawyer',
    occupation: 'Lawyer',
    education: ['Juris Doctor', 'BA Legal Management'],
    publicIdentity:
        'Civic lawyer promising institutional and procurement reform',
    archetype: 'Legal reform candidate',
    currentPosition: 'Public-interest attorney',
    primaryIndicators: [
      CityIndicator.publicTrust,
      CityIndicator.corruptionPressure,
      CityIndicator.budgetHealth,
    ],
    rhetoricalStyles: [
      CandidateRhetoricalStyle.aggressive,
      CandidateRhetoricalStyle.conciliatory,
      CandidateRhetoricalStyle.statisticHeavy,
    ],
    baseExperience: 45,
    weight: 7,
  ),
];

class PromiseTemplate {
  const PromiseTemplate({
    required this.family,
    required this.title,
    required this.wording,
    required this.approach,
    required this.complexity,
  });

  final CityIssueFamily family;
  final String title;
  final String wording;
  final String approach;
  final CandidatePromiseComplexity complexity;
}

const proceduralPromiseLibrary = <PromiseTemplate>[
  PromiseTemplate(
    family: CityIssueFamily.floodingDrainage,
    title: 'Flood-ready neighborhoods',
    wording:
        'We will clear the bottlenecks and publish a district-by-district flood schedule.',
    approach:
        'Sequence drainage clearing, pump maintenance, and public hotspot reporting.',
    complexity: CandidatePromiseComplexity.capitalProject,
  ),
  PromiseTemplate(
    family: CityIssueFamily.corruptionPublicFunds,
    title: 'Open contract ledger',
    wording:
        'Every major contract should be searchable before the first payment is released.',
    approach:
        'Publish bids, beneficial ownership declarations, milestones, and change orders.',
    complexity: CandidatePromiseComplexity.structuralReform,
  ),
  PromiseTemplate(
    family: CityIssueFamily.unfinishedRoads,
    title: 'Finish what was funded',
    wording:
        'No new ribbon cutting while paid road projects remain unfinished.',
    approach:
        'Audit stalled works, publish completion dates, and prioritize unsafe corridors.',
    complexity: CandidatePromiseComplexity.capitalProject,
  ),
  PromiseTemplate(
    family: CityIssueFamily.drugsCommunitySafety,
    title: 'Safer streets with accountable enforcement',
    wording:
        'Safety should combine prevention, fast response, and public oversight.',
    approach:
        'Coordinate neighborhood response teams, treatment referrals, and transparent incident reporting.',
    complexity: CandidatePromiseComplexity.multiAgency,
  ),
  PromiseTemplate(
    family: CityIssueFamily.garbageCleanliness,
    title: 'Reliable collection by district',
    wording:
        'Every neighborhood deserves a collection schedule residents can actually trust.',
    approach:
        'Publish routes, repair the vehicle fleet, and enforce contractor performance clauses.',
    complexity: CandidatePromiseComplexity.focusedProgram,
  ),
  PromiseTemplate(
    family: CityIssueFamily.trafficTransport,
    title: 'Move people, not bottlenecks',
    wording:
        'We will make daily transport predictable before announcing prestige projects.',
    approach:
        'Redesign routes, protect transfer points, and use travel-time data to sequence fixes.',
    complexity: CandidatePromiseComplexity.multiAgency,
  ),
  PromiseTemplate(
    family: CityIssueFamily.waterSupply,
    title: 'Safe water block by block',
    wording:
        'Water testing and the highest-risk line repairs will begin in the first hundred days.',
    approach:
        'Deploy mobile testing, publish contamination results, and replace risk-ranked pipes.',
    complexity: CandidatePromiseComplexity.capitalProject,
  ),
  PromiseTemplate(
    family: CityIssueFamily.healthcareCapacity,
    title: 'Care closer to home',
    wording:
        'Clinics should stay open when working families can actually reach them.',
    approach:
        'Extend clinic hours, pool medicine purchasing, and rotate mobile teams through underserved areas.',
    complexity: CandidatePromiseComplexity.multiAgency,
  ),
  PromiseTemplate(
    family: CityIssueFamily.employmentQuality,
    title: 'Jobs that last',
    wording:
        'City incentives must reward stable work, not short contracts that disappear after launch day.',
    approach:
        'Tie incentives to retention, apprenticeships, wage standards, and public reporting.',
    complexity: CandidatePromiseComplexity.structuralReform,
  ),
  PromiseTemplate(
    family: CityIssueFamily.costOfLiving,
    title: 'Lower the daily squeeze',
    wording:
        'Families need practical relief from food, transport, and permit costs.',
    approach:
        'Coordinate market logistics, targeted assistance, and fee reviews with published eligibility rules.',
    complexity: CandidatePromiseComplexity.multiAgency,
  ),
  PromiseTemplate(
    family: CityIssueFamily.governmentServices,
    title: 'One accountable service desk',
    wording:
        'Residents should not need five offices to solve one city problem.',
    approach:
        'Create trackable requests, common service standards, and public resolution times.',
    complexity: CandidatePromiseComplexity.structuralReform,
  ),
  PromiseTemplate(
    family: CityIssueFamily.educationCapacity,
    title: 'Room to learn',
    wording:
        'Crowded schools need classrooms, teachers, and support services—not slogans.',
    approach:
        'Prioritize high-load schools, teacher support, and transparent facility schedules.',
    complexity: CandidatePromiseComplexity.capitalProject,
  ),
];

CityIndicator indicatorForIssueFamily(CityIssueFamily family) =>
    switch (family) {
      CityIssueFamily.floodingDrainage => CityIndicator.climateResilience,
      CityIssueFamily.corruptionPublicFunds => CityIndicator.corruptionPressure,
      CityIssueFamily.unfinishedRoads => CityIndicator.urbanResilience,
      CityIssueFamily.drugsCommunitySafety => CityIndicator.publicTrust,
      CityIssueFamily.garbageCleanliness => CityIndicator.urbanResilience,
      CityIssueFamily.trafficTransport => CityIndicator.urbanResilience,
      CityIssueFamily.waterSupply => CityIndicator.waterSecurity,
      CityIssueFamily.healthcareCapacity => CityIndicator.publicHealth,
      CityIssueFamily.employmentQuality => CityIndicator.employmentQuality,
      CityIssueFamily.costOfLiving => CityIndicator.foodSecurity,
      CityIssueFamily.governmentServices => CityIndicator.publicTrust,
      CityIssueFamily.educationCapacity => CityIndicator.educationQuality,
    };
