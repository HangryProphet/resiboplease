import '../../domain/models/city_indicator.dart';
import '../../domain/models/city_problem.dart';
import '../../domain/models/living_city_simulation.dart';

class LivingEventTemplate {
  const LivingEventTemplate({
    required this.id,
    required this.category,
    required this.baseWeight,
    required this.title,
    required this.summary,
    required this.explanation,
    required this.markerType,
    required this.district,
    required this.indicatorEffects,
    this.issueFamily,
    this.severity = CityEventSeverity.minor,
    this.minimumPhase = 1,
    this.maximumPhase = 4,
    this.conditionIndicator,
    this.conditionBelow,
    this.conditionAbove,
    this.requiredHook,
    this.followUpHooks = const [],
    this.cooldownDays = 45,
    this.followUpDelayDays = 8,
    this.followUpWindowDays = 75,
    this.preferredLocationIds = const [],
    this.chainFamily,
    this.repeatable = false,
    this.visualAssetKey,
  });

  final String id;
  final CityEventCategory category;
  final double baseWeight;
  final String title;
  final String summary;
  final String explanation;
  final CityMapMarkerType markerType;
  final CitySimulationDistrict district;
  final Map<CityIndicator, int> indicatorEffects;
  final CityIssueFamily? issueFamily;
  final CityEventSeverity severity;
  final int minimumPhase;
  final int maximumPhase;
  final CityIndicator? conditionIndicator;
  final int? conditionBelow;
  final int? conditionAbove;
  final String? requiredHook;
  final List<String> followUpHooks;
  final int cooldownDays;
  final int followUpDelayDays;
  final int followUpWindowDays;
  final List<String> preferredLocationIds;
  final String? chainFamily;
  final bool repeatable;
  final String? visualAssetKey;

  String get effectiveChainFamily => chainFamily ?? id;
}

/// Authored facts and effects; selection and magnitude remain procedural.
const livingCityEventLibrary = <LivingEventTemplate>[
  LivingEventTemplate(
    id: 'drainage_overflow',
    category: CityEventCategory.issueDriven,
    baseWeight: 1.35,
    title: 'Drainage channels overflow',
    summary:
        'Heavy rain pushes water into low streets and interrupts neighborhood travel.',
    explanation:
        'Flood exposure and climate readiness determine how far the disruption spreads.',
    markerType: CityMapMarkerType.flood,
    district: CitySimulationDistrict.riverside,
    issueFamily: CityIssueFamily.floodingDrainage,
    severity: CityEventSeverity.major,
    indicatorEffects: {
      CityIndicator.climateResilience: -3,
      CityIndicator.urbanResilience: -2,
      CityIndicator.publicTrust: -1,
    },
    followUpHooks: ['cleanup_needed'],
    chainFamily: 'flood_recovery',
    preferredLocationIds: ['riverside', 'west_residential'],
    visualAssetKey: 'assets/images/events/typhoon_response.jpg',
  ),
  LivingEventTemplate(
    id: 'cleanup_drive',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: 2.2,
    title: 'Neighbors organize a cleanup drive',
    summary:
        'Volunteer groups clear drains and help affected households reopen their streets.',
    explanation:
        'A recovery event can soften an earlier flood without erasing its consequences.',
    markerType: CityMapMarkerType.community,
    district: CitySimulationDistrict.riverside,
    requiredHook: 'cleanup_needed',
    chainFamily: 'flood_recovery',
    severity: CityEventSeverity.minor,
    indicatorEffects: {
      CityIndicator.climateResilience: 1,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'water_line_break',
    category: CityEventCategory.issueDriven,
    baseWeight: 1.3,
    title: 'A water main fails overnight',
    summary:
        'Crews isolate a damaged line while residents queue at emergency water stations.',
    explanation:
        'Weak water security raises the chance and cost of a service interruption.',
    markerType: CityMapMarkerType.water,
    district: CitySimulationDistrict.southPoint,
    issueFamily: CityIssueFamily.waterSupply,
    severity: CityEventSeverity.major,
    indicatorEffects: {
      CityIndicator.waterSecurity: -4,
      CityIndicator.publicHealth: -1,
      CityIndicator.publicTrust: -1,
    },
    followUpHooks: ['water_repair'],
    chainFamily: 'water_service',
    visualAssetKey: 'assets/images/events/water_emergency.jpg',
  ),
  LivingEventTemplate(
    id: 'water_repair_complete',
    category: CityEventCategory.administration,
    baseWeight: 2.4,
    title: 'Repair crews restore the main line',
    summary:
        'Pressure returns gradually after testing identifies and seals the damaged section.',
    explanation:
        'Follow-up work restores part of the lost capacity, depending on administrative execution.',
    markerType: CityMapMarkerType.water,
    district: CitySimulationDistrict.southPoint,
    requiredHook: 'water_repair',
    chainFamily: 'water_service',
    indicatorEffects: {
      CityIndicator.waterSecurity: 2,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'clinic_surge',
    category: CityEventCategory.issueDriven,
    baseWeight: 1.25,
    title: 'Clinics face a patient surge',
    summary:
        'Respiratory cases fill waiting rooms and force several clinics to extend triage hours.',
    explanation:
        'Health capacity and crisis preparation shape the administration response.',
    markerType: CityMapMarkerType.clinic,
    district: CitySimulationDistrict.northWard,
    issueFamily: CityIssueFamily.healthcareCapacity,
    severity: CityEventSeverity.major,
    indicatorEffects: {
      CityIndicator.publicHealth: -4,
      CityIndicator.budgetHealth: -1,
      CityIndicator.publicTrust: -1,
    },
    followUpHooks: ['clinic_recovery'],
    chainFamily: 'health_surge',
    preferredLocationIds: ['hospital'],
    visualAssetKey: 'assets/images/events/clinic_outbreak.jpg',
  ),
  LivingEventTemplate(
    id: 'clinic_mobile_units',
    category: CityEventCategory.administration,
    baseWeight: 2.3,
    title: 'Mobile clinics reach crowded wards',
    summary:
        'Temporary health teams bring consultations and medicine closer to vulnerable blocks.',
    explanation:
        'A competent recovery can contain the surge while adding a modest budget cost.',
    markerType: CityMapMarkerType.clinic,
    district: CitySimulationDistrict.northWard,
    requiredHook: 'clinic_recovery',
    chainFamily: 'health_surge',
    indicatorEffects: {
      CityIndicator.publicHealth: 2,
      CityIndicator.budgetHealth: -1,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'factory_closure',
    category: CityEventCategory.externalShock,
    baseWeight: 1.05,
    title: 'A waterfront factory closes',
    summary:
        'Hundreds of workers receive final notices as nearby businesses prepare for fewer customers.',
    explanation:
        'The closure is external; employment conditions determine how deeply it harms families.',
    markerType: CityMapMarkerType.jobs,
    district: CitySimulationDistrict.industrialBelt,
    issueFamily: CityIssueFamily.employmentQuality,
    severity: CityEventSeverity.major,
    indicatorEffects: {
      CityIndicator.employmentQuality: -4,
      CityIndicator.povertyReduction: -2,
      CityIndicator.foodSecurity: -1,
    },
    followUpHooks: ['displaced_workers'],
    chainFamily: 'employment_shock',
    preferredLocationIds: ['industrial_zone'],
    visualAssetKey: 'assets/images/events/jobs_shock.jpg',
  ),
  LivingEventTemplate(
    id: 'job_fair',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: 2.0,
    title: 'Employers open a city job fair',
    summary:
        'Local firms offer interviews and short training sessions to displaced workers.',
    explanation:
        'A recovery opportunity helps, but cannot instantly replace every lost job.',
    markerType: CityMapMarkerType.jobs,
    district: CitySimulationDistrict.oldMarket,
    requiredHook: 'displaced_workers',
    chainFamily: 'employment_shock',
    indicatorEffects: {
      CityIndicator.employmentQuality: 2,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'road_collapse',
    category: CityEventCategory.issueDriven,
    baseWeight: 1.1,
    title: 'A key road section gives way',
    summary:
        'Buses reroute around a damaged corridor while engineers assess the buried drainage bed.',
    explanation:
        'Urban resilience and unfinished-road pressure affect the size of the disruption.',
    markerType: CityMapMarkerType.transport,
    district: CitySimulationDistrict.harborDistrict,
    issueFamily: CityIssueFamily.unfinishedRoads,
    severity: CityEventSeverity.major,
    indicatorEffects: {
      CityIndicator.urbanResilience: -4,
      CityIndicator.employmentQuality: -1,
      CityIndicator.budgetHealth: -1,
    },
    followUpHooks: ['road_repair'],
    chainFamily: 'road_disruption',
    visualAssetKey: 'assets/images/events/transport_disruption.jpg',
  ),
  LivingEventTemplate(
    id: 'temporary_shuttles',
    category: CityEventCategory.administration,
    baseWeight: 2.1,
    title: 'Temporary shuttles bridge the closure',
    summary: 'The city deploys a limited bus loop while road repairs continue.',
    explanation:
        'Coordination reduces the mobility loss but does not complete the capital work.',
    markerType: CityMapMarkerType.transport,
    district: CitySimulationDistrict.harborDistrict,
    requiredHook: 'road_repair',
    chainFamily: 'road_disruption',
    indicatorEffects: {
      CityIndicator.urbanResilience: 1,
      CityIndicator.publicTrust: 1,
      CityIndicator.budgetHealth: -1,
    },
  ),
  LivingEventTemplate(
    id: 'procurement_questions',
    category: CityEventCategory.political,
    baseWeight: .8,
    title: 'Procurement questions reach council',
    summary:
        'Reporters trace unusual bidding patterns around a visible city contract.',
    explanation:
        'Integrity and corruption exposure determine whether questions become a wider inquiry.',
    markerType: CityMapMarkerType.audit,
    district: CitySimulationDistrict.civicCenter,
    severity: CityEventSeverity.moderate,
    minimumPhase: 2,
    indicatorEffects: {
      CityIndicator.corruptionPressure: 3,
      CityIndicator.publicTrust: -2,
      CityIndicator.budgetHealth: -1,
    },
    followUpHooks: ['audit_pending'],
    chainFamily: 'procurement_audit',
  ),
  LivingEventTemplate(
    id: 'records_released',
    category: CityEventCategory.political,
    baseWeight: 1.8,
    title: 'Contract records are released',
    summary:
        'Procurement files become available for public review after mounting questions.',
    explanation:
        'Transparency can rebuild trust, although it may also expose unresolved weaknesses.',
    markerType: CityMapMarkerType.audit,
    district: CitySimulationDistrict.civicCenter,
    requiredHook: 'audit_pending',
    chainFamily: 'procurement_audit',
    indicatorEffects: {
      CityIndicator.corruptionPressure: -2,
      CityIndicator.publicTrust: 2,
    },
  ),
  LivingEventTemplate(
    id: 'council_deadlock',
    category: CityEventCategory.political,
    baseWeight: .8,
    title: 'Council deadlock delays a vote',
    summary:
        'A divided council postpones an appropriation vote and sends the measure back to committee.',
    explanation:
        'Coalition skill affects how long administrative priorities remain stalled.',
    markerType: CityMapMarkerType.government,
    district: CitySimulationDistrict.civicCenter,
    severity: CityEventSeverity.moderate,
    indicatorEffects: {
      CityIndicator.publicTrust: -2,
      CityIndicator.budgetHealth: -1,
    },
  ),
  LivingEventTemplate(
    id: 'budget_revision',
    category: CityEventCategory.administration,
    baseWeight: .85,
    title: 'City hall revises its spending plan',
    summary:
        'Departments are ordered to protect essential services while postponing lower-priority purchases.',
    explanation:
        'Budget discipline can preserve capacity, but cuts carry visible trade-offs.',
    markerType: CityMapMarkerType.government,
    district: CitySimulationDistrict.civicCenter,
    conditionIndicator: CityIndicator.budgetHealth,
    conditionBelow: 48,
    indicatorEffects: {
      CityIndicator.budgetHealth: 2,
      CityIndicator.publicTrust: -1,
    },
  ),
  LivingEventTemplate(
    id: 'school_repairs',
    category: CityEventCategory.administration,
    baseWeight: .72,
    title: 'School repair teams start work',
    summary:
        'Roof and sanitation repairs begin at several crowded public schools.',
    explanation:
        'Routine delivery can improve daily services without becoming a major crisis headline.',
    markerType: CityMapMarkerType.school,
    district: CitySimulationDistrict.hillview,
    issueFamily: CityIssueFamily.educationCapacity,
    preferredLocationIds: ['school_district'],
    indicatorEffects: {
      CityIndicator.educationQuality: 2,
      CityIndicator.budgetHealth: -1,
    },
  ),
  LivingEventTemplate(
    id: 'market_prices_rise',
    category: CityEventCategory.indicatorDriven,
    baseWeight: .88,
    title: 'Market baskets become more expensive',
    summary:
        'Staple prices climb across neighborhood markets after a difficult regional harvest.',
    explanation:
        'Food and poverty indicators govern how severely households feel a price shock.',
    markerType: CityMapMarkerType.market,
    district: CitySimulationDistrict.oldMarket,
    conditionIndicator: CityIndicator.foodSecurity,
    conditionBelow: 58,
    severity: CityEventSeverity.moderate,
    preferredLocationIds: ['public_market'],
    indicatorEffects: {
      CityIndicator.foodSecurity: -3,
      CityIndicator.povertyReduction: -2,
      CityIndicator.publicTrust: -1,
    },
  ),
  LivingEventTemplate(
    id: 'cooperative_delivery',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: .75,
    title: 'Cooperatives expand food deliveries',
    summary:
        'Farmer and fisher groups add direct deliveries to two neighborhood markets.',
    explanation:
        'A positive opening produces a small but meaningful improvement in food access.',
    markerType: CityMapMarkerType.market,
    district: CitySimulationDistrict.oldMarket,
    indicatorEffects: {
      CityIndicator.foodSecurity: 2,
      CityIndicator.employmentQuality: 1,
    },
  ),
  LivingEventTemplate(
    id: 'waste_backlog',
    category: CityEventCategory.issueDriven,
    baseWeight: .9,
    title: 'Waste collection falls behind',
    summary:
        'Missed pickups leave several blocks with overflowing communal bins.',
    explanation:
        'Service capacity and cleanliness pressure shape how quickly a backlog grows.',
    markerType: CityMapMarkerType.waste,
    district: CitySimulationDistrict.southPoint,
    issueFamily: CityIssueFamily.garbageCleanliness,
    indicatorEffects: {
      CityIndicator.publicHealth: -1,
      CityIndicator.urbanResilience: -2,
      CityIndicator.publicTrust: -1,
    },
  ),
  LivingEventTemplate(
    id: 'night_market',
    category: CityEventCategory.cityLife,
    baseWeight: 1.0,
    title: 'A night market fills the plaza',
    summary:
        'Food stalls, musicians, and small vendors draw residents into the civic center.',
    explanation:
        'City life continues between crises and provides modest social and economic lift.',
    markerType: CityMapMarkerType.festival,
    district: CitySimulationDistrict.civicCenter,
    severity: CityEventSeverity.ambient,
    preferredLocationIds: ['city_plaza'],
    indicatorEffects: {
      CityIndicator.employmentQuality: 1,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'barangay_basketball',
    category: CityEventCategory.cityLife,
    baseWeight: 1.0,
    title: 'Neighborhood teams fill the courts',
    summary:
        'A weekend basketball league draws families and vendors to North Ward.',
    explanation:
        'An ordinary civic moment makes the city feel alive without changing policy direction.',
    markerType: CityMapMarkerType.community,
    district: CitySimulationDistrict.northWard,
    severity: CityEventSeverity.ambient,
    indicatorEffects: {CityIndicator.publicTrust: 1},
  ),
  LivingEventTemplate(
    id: 'harbor_festival',
    category: CityEventCategory.cityLife,
    baseWeight: .8,
    title: 'Harbor festival opens at sunset',
    summary:
        'Boats, food stalls, and local performers bring a calm evening to the waterfront.',
    explanation:
        'A seeded city-life event adds texture and a small trust benefit.',
    markerType: CityMapMarkerType.festival,
    district: CitySimulationDistrict.harborDistrict,
    severity: CityEventSeverity.ambient,
    indicatorEffects: {
      CityIndicator.publicTrust: 1,
      CityIndicator.employmentQuality: 1,
    },
  ),
  LivingEventTemplate(
    id: 'power_interruptions',
    category: CityEventCategory.externalShock,
    baseWeight: .72,
    title: 'Rolling outages hit three districts',
    summary:
        'A regional grid fault interrupts shops, traffic signals, and evening classes.',
    explanation:
        'The shock is outside city hall, but resilience influences its local consequences.',
    markerType: CityMapMarkerType.power,
    district: CitySimulationDistrict.industrialBelt,
    severity: CityEventSeverity.moderate,
    preferredLocationIds: ['industrial_zone'],
    indicatorEffects: {
      CityIndicator.urbanResilience: -2,
      CityIndicator.employmentQuality: -1,
    },
  ),
  LivingEventTemplate(
    id: 'regional_grant',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: .45,
    title: 'Bayhaven wins a resilience grant',
    summary:
        'A competitive regional grant gives the city new room for drainage and shelter upgrades.',
    explanation:
        'Some opportunities are genuinely fortunate; implementation still decides their value.',
    markerType: CityMapMarkerType.opportunity,
    district: CitySimulationDistrict.civicCenter,
    severity: CityEventSeverity.moderate,
    minimumPhase: 2,
    indicatorEffects: {
      CityIndicator.budgetHealth: 3,
      CityIndicator.climateResilience: 2,
    },
  ),
  LivingEventTemplate(
    id: 'small_business_wave',
    category: CityEventCategory.indicatorDriven,
    baseWeight: .58,
    title: 'New permits lift small business activity',
    summary:
        'A wave of food, repair, and service businesses opens across Old Market.',
    explanation:
        'Stronger employment conditions make this positive indicator event more likely.',
    markerType: CityMapMarkerType.jobs,
    district: CitySimulationDistrict.oldMarket,
    indicatorEffects: {
      CityIndicator.employmentQuality: 2,
      CityIndicator.povertyReduction: 1,
    },
  ),
  LivingEventTemplate(
    id: 'protest_at_city_hall',
    category: CityEventCategory.political,
    baseWeight: .58,
    title: 'Residents rally outside city hall',
    summary:
        'Community groups demand clearer project timelines and public spending records.',
    explanation:
        'Low trust and delayed delivery make organized dissent more likely.',
    markerType: CityMapMarkerType.protest,
    district: CitySimulationDistrict.civicCenter,
    conditionIndicator: CityIndicator.publicTrust,
    conditionBelow: 48,
    severity: CityEventSeverity.moderate,
    preferredLocationIds: ['city_hall', 'city_plaza'],
    indicatorEffects: {CityIndicator.publicTrust: -1},
  ),
  LivingEventTemplate(
    id: 'watchdog_award',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: .36,
    title: 'Open-records work earns recognition',
    summary:
        'A civic watchdog cites Bayhaven for publishing readable contract and project records.',
    explanation:
        'High-integrity administrations have a better chance to convert transparency into trust.',
    markerType: CityMapMarkerType.audit,
    district: CitySimulationDistrict.civicCenter,
    minimumPhase: 3,
    indicatorEffects: {
      CityIndicator.publicTrust: 3,
      CityIndicator.corruptionPressure: -2,
    },
  ),
  LivingEventTemplate(
    id: 'unexpected_sinkhole',
    category: CityEventCategory.rare,
    baseWeight: .12,
    title: 'A sinkhole opens below a quiet street',
    summary:
        'A buried utility failure opens a deep cavity and forces an unusual emergency evacuation.',
    explanation:
        'Rare events are seed-driven surprises with real but bounded consequences.',
    markerType: CityMapMarkerType.roadworks,
    district: CitySimulationDistrict.hillview,
    severity: CityEventSeverity.rare,
    indicatorEffects: {
      CityIndicator.urbanResilience: -3,
      CityIndicator.budgetHealth: -2,
    },
    followUpHooks: ['road_repair'],
  ),
  LivingEventTemplate(
    id: 'anonymous_documents',
    category: CityEventCategory.rare,
    baseWeight: .1,
    title: 'Anonymous files reach the Chronicle',
    summary:
        'A packet of incomplete contract records prompts verification before publication.',
    explanation:
        'The rare leak creates scrutiny without treating an allegation as proven fact.',
    markerType: CityMapMarkerType.news,
    district: CitySimulationDistrict.civicCenter,
    severity: CityEventSeverity.rare,
    minimumPhase: 2,
    indicatorEffects: {
      CityIndicator.publicTrust: -1,
      CityIndicator.corruptionPressure: 1,
    },
    followUpHooks: ['audit_pending'],
  ),
  LivingEventTemplate(
    id: 'mangrove_recovery',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: .5,
    title: 'Young mangroves take root',
    summary:
        'A community shoreline plot survives the season and begins protecting a vulnerable bank.',
    explanation:
        'Environmental recovery can emerge slowly from earlier preparation and luck.',
    markerType: CityMapMarkerType.opportunity,
    district: CitySimulationDistrict.riverside,
    minimumPhase: 2,
    indicatorEffects: {
      CityIndicator.climateResilience: 2,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'service_queue_reform',
    category: CityEventCategory.administration,
    baseWeight: .62,
    title: 'Permit queues move to a one-stop desk',
    summary:
        'Residents can now submit several common applications at one city service counter.',
    explanation:
        'Administrative competence produces small, visible gains beyond headline projects.',
    markerType: CityMapMarkerType.government,
    district: CitySimulationDistrict.civicCenter,
    issueFamily: CityIssueFamily.governmentServices,
    indicatorEffects: {
      CityIndicator.publicTrust: 2,
      CityIndicator.employmentQuality: 1,
    },
  ),
  LivingEventTemplate(
    id: 'traffic_enforcement_week',
    category: CityEventCategory.administration,
    baseWeight: .62,
    title: 'Traffic teams retime busy junctions',
    summary:
        'Signal changes and loading-zone enforcement shorten some peak-hour delays.',
    explanation:
        'A modest operational intervention can help without solving the whole transport problem.',
    markerType: CityMapMarkerType.transport,
    district: CitySimulationDistrict.oldMarket,
    issueFamily: CityIssueFamily.trafficTransport,
    indicatorEffects: {
      CityIndicator.urbanResilience: 2,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'community_patrols',
    category: CityEventCategory.cityLife,
    baseWeight: .62,
    title: 'Night patrol volunteers coordinate',
    summary:
        'Residents and local officers agree on safer routes around schools and markets.',
    explanation:
        'Community coordination produces a small safety and trust benefit.',
    markerType: CityMapMarkerType.publicSafety,
    district: CitySimulationDistrict.northWard,
    issueFamily: CityIssueFamily.drugsCommunitySafety,
    indicatorEffects: {
      CityIndicator.publicTrust: 1,
      CityIndicator.urbanResilience: 1,
    },
  ),
  LivingEventTemplate(
    id: 'heavy_rain_watch',
    category: CityEventCategory.externalShock,
    baseWeight: .82,
    title: 'Heavy rain settles over the city',
    summary:
        'Hours of steady rain saturate roadside drains and slow travel through low districts.',
    explanation:
        'Rain is an outside event; drainage condition and local resilience shape what can follow.',
    markerType: CityMapMarkerType.weather,
    district: CitySimulationDistrict.riverside,
    severity: CityEventSeverity.moderate,
    indicatorEffects: {CityIndicator.climateResilience: -1},
    followUpHooks: ['saturated_drainage'],
    chainFamily: 'storm_water_health',
    preferredLocationIds: ['riverside'],
  ),
  LivingEventTemplate(
    id: 'flood_after_heavy_rain',
    category: CityEventCategory.issueDriven,
    baseWeight: 2.5,
    title: 'Floodwater enters riverside streets',
    summary:
        'Saturated drains push dirty water into homes, shops, and a busy neighborhood road.',
    explanation:
        'The earlier rain combines with existing drainage pressure instead of creating an unrelated crisis.',
    markerType: CityMapMarkerType.flood,
    district: CitySimulationDistrict.riverside,
    issueFamily: CityIssueFamily.floodingDrainage,
    severity: CityEventSeverity.major,
    requiredHook: 'saturated_drainage',
    followUpHooks: ['contaminated_runoff'],
    chainFamily: 'storm_water_health',
    preferredLocationIds: ['riverside'],
    indicatorEffects: {
      CityIndicator.climateResilience: -3,
      CityIndicator.urbanResilience: -2,
      CityIndicator.publicTrust: -1,
    },
    visualAssetKey: 'assets/images/events/typhoon_response.jpg',
  ),
  LivingEventTemplate(
    id: 'water_contamination_after_flood',
    category: CityEventCategory.issueDriven,
    baseWeight: 2.2,
    title: 'Water testing finds contamination',
    summary:
        'Flood runoff reaches a damaged service line and triggers a boil-water advisory.',
    explanation:
        'This health risk requires an earlier runoff event and cannot appear as an impossible isolated fact.',
    markerType: CityMapMarkerType.water,
    district: CitySimulationDistrict.southPoint,
    issueFamily: CityIssueFamily.waterSupply,
    severity: CityEventSeverity.critical,
    requiredHook: 'contaminated_runoff',
    followUpHooks: ['clinic_recovery'],
    chainFamily: 'storm_water_health',
    preferredLocationIds: ['south_residential', 'hospital'],
    indicatorEffects: {
      CityIndicator.waterSecurity: -4,
      CityIndicator.publicHealth: -3,
      CityIndicator.publicTrust: -2,
    },
    visualAssetKey: 'assets/images/events/water_emergency.jpg',
  ),
  LivingEventTemplate(
    id: 'central_avenue_roadworks',
    category: CityEventCategory.administration,
    baseWeight: .78,
    title: 'Central Avenue roadworks begin',
    summary:
        'Crews close two lanes as a rehabilitation project moves from plans into street work.',
    explanation:
        'Visible construction can create temporary costs before any long-term benefit arrives.',
    markerType: CityMapMarkerType.roadworks,
    district: CitySimulationDistrict.civicCenter,
    issueFamily: CityIssueFamily.unfinishedRoads,
    severity: CityEventSeverity.moderate,
    followUpHooks: ['roadworks_traffic'],
    chainFamily: 'central_avenue_project',
    preferredLocationIds: ['central_avenue'],
    indicatorEffects: {
      CityIndicator.budgetHealth: -1,
      CityIndicator.urbanResilience: 1,
    },
    visualAssetKey: 'assets/images/events/transport_disruption.jpg',
  ),
  LivingEventTemplate(
    id: 'roadworks_congestion',
    category: CityEventCategory.issueDriven,
    baseWeight: 2.1,
    title: 'Traffic builds around the work zone',
    summary:
        'Buses and deliveries crowd side streets while Central Avenue remains partly closed.',
    explanation: 'This disruption only becomes eligible after roadworks begin.',
    markerType: CityMapMarkerType.transport,
    district: CitySimulationDistrict.civicCenter,
    issueFamily: CityIssueFamily.trafficTransport,
    severity: CityEventSeverity.moderate,
    requiredHook: 'roadworks_traffic',
    followUpHooks: ['roadworks_business_pressure'],
    chainFamily: 'central_avenue_project',
    preferredLocationIds: ['central_avenue', 'transport_terminal'],
    indicatorEffects: {
      CityIndicator.urbanResilience: -2,
      CityIndicator.employmentQuality: -1,
    },
  ),
  LivingEventTemplate(
    id: 'roadworks_business_complaints',
    category: CityEventCategory.political,
    baseWeight: 1.9,
    title: 'Shops question the roadwork schedule',
    summary:
        'Small businesses near Central Avenue report fewer customers and demand a clearer completion date.',
    explanation:
        'Public criticism grows from the saved construction chain rather than a separate invented controversy.',
    markerType: CityMapMarkerType.market,
    district: CitySimulationDistrict.oldMarket,
    severity: CityEventSeverity.moderate,
    requiredHook: 'roadworks_business_pressure',
    chainFamily: 'central_avenue_project',
    preferredLocationIds: ['commercial_center'],
    indicatorEffects: {
      CityIndicator.employmentQuality: -1,
      CityIndicator.publicTrust: -1,
    },
  ),
  LivingEventTemplate(
    id: 'heat_wave',
    category: CityEventCategory.externalShock,
    baseWeight: .62,
    title: 'A heat wave strains daily routines',
    summary:
        'Hot afternoons shorten outdoor work hours and increase demand at public clinics.',
    explanation:
        'Climate and health readiness influence the local cost of a regional weather event.',
    markerType: CityMapMarkerType.weather,
    district: CitySimulationDistrict.northWard,
    severity: CityEventSeverity.moderate,
    minimumPhase: 2,
    maximumPhase: 3,
    preferredLocationIds: ['hospital', 'north_residential'],
    indicatorEffects: {
      CityIndicator.publicHealth: -2,
      CityIndicator.climateResilience: -1,
    },
  ),
  LivingEventTemplate(
    id: 'fuel_price_jump',
    category: CityEventCategory.externalShock,
    baseWeight: .58,
    title: 'Fuel prices climb across the region',
    summary:
        'Transport operators and delivery businesses warn that operating costs are rising.',
    explanation:
        'The price increase is external, while mobility and household conditions determine its local reach.',
    markerType: CityMapMarkerType.transport,
    district: CitySimulationDistrict.harborDistrict,
    severity: CityEventSeverity.moderate,
    preferredLocationIds: ['transport_terminal'],
    indicatorEffects: {
      CityIndicator.employmentQuality: -1,
      CityIndicator.foodSecurity: -1,
      CityIndicator.publicTrust: -1,
    },
  ),
  LivingEventTemplate(
    id: 'clinic_recognition',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: .72,
    title: 'Clinic teams earn service recognition',
    summary:
        'A regional health network recognizes shorter waiting times and stronger follow-up care.',
    explanation:
        'Strong public-health conditions make this positive event plausible rather than automatic.',
    markerType: CityMapMarkerType.clinic,
    district: CitySimulationDistrict.northWard,
    severity: CityEventSeverity.minor,
    conditionIndicator: CityIndicator.publicHealth,
    conditionAbove: 58,
    preferredLocationIds: ['hospital'],
    indicatorEffects: {
      CityIndicator.publicHealth: 1,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'student_science_win',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: .68,
    title: 'Public-school team wins science honors',
    summary:
        'Students return from a regional competition with awards for a low-cost flood sensor.',
    explanation:
        'Education strength creates opportunities that are not simply crisis recovery.',
    markerType: CityMapMarkerType.school,
    district: CitySimulationDistrict.hillview,
    conditionIndicator: CityIndicator.educationQuality,
    conditionAbove: 55,
    preferredLocationIds: ['school_district'],
    indicatorEffects: {
      CityIndicator.educationQuality: 2,
      CityIndicator.publicTrust: 1,
    },
  ),
  LivingEventTemplate(
    id: 'commercial_expansion',
    category: CityEventCategory.positiveOpportunity,
    baseWeight: .62,
    title: 'Local firms open a shared workshop',
    summary:
        'Small manufacturers pool equipment and add new skilled jobs near the commercial center.',
    explanation:
        'Healthy employment makes investment more plausible, but the exact timing remains seeded.',
    markerType: CityMapMarkerType.opportunity,
    district: CitySimulationDistrict.oldMarket,
    conditionIndicator: CityIndicator.employmentQuality,
    conditionAbove: 58,
    preferredLocationIds: ['commercial_center'],
    indicatorEffects: {
      CityIndicator.employmentQuality: 2,
      CityIndicator.povertyReduction: 1,
    },
  ),
  LivingEventTemplate(
    id: 'city_hall_cat_returns',
    category: CityEventCategory.cityLife,
    baseWeight: .95,
    title: 'The City Hall cat returns',
    summary:
        'Employees find the unofficial City Hall cat asleep in its usual spot near the steps.',
    explanation:
        'The city sometimes records ordinary stories with no policy consequence.',
    markerType: CityMapMarkerType.community,
    district: CitySimulationDistrict.civicCenter,
    severity: CityEventSeverity.ambient,
    preferredLocationIds: ['city_hall'],
    indicatorEffects: {},
  ),
  LivingEventTemplate(
    id: 'squidball_price_protest',
    category: CityEventCategory.cityLife,
    baseWeight: .62,
    title: 'Squidball price protest confuses the plaza',
    summary:
        'A half-serious rally demands cheaper squidballs before turning into a lively street-food debate.',
    explanation:
        'A harmless civic oddity adds personality without changing the administration score.',
    markerType: CityMapMarkerType.protest,
    district: CitySimulationDistrict.civicCenter,
    severity: CityEventSeverity.ambient,
    preferredLocationIds: ['city_plaza'],
    indicatorEffects: {},
  ),
  LivingEventTemplate(
    id: 'rainy_day_proposal',
    category: CityEventCategory.cityLife,
    baseWeight: .68,
    title: 'A rainy-day proposal stops traffic',
    summary:
        'Commuters cheer when a marriage proposal unfolds beneath one umbrella at the terminal.',
    explanation:
        'The story has no measurable city effect but remains part of this save\'s history.',
    markerType: CityMapMarkerType.community,
    district: CitySimulationDistrict.harborDistrict,
    severity: CityEventSeverity.ambient,
    preferredLocationIds: ['transport_terminal'],
    indicatorEffects: {},
  ),
  LivingEventTemplate(
    id: 'viral_tricycle_art',
    category: CityEventCategory.cityLife,
    baseWeight: .72,
    title: 'A decorated tricycle becomes a local star',
    summary:
        'A driver\'s elaborate sea-monster paintwork draws photos across the transport terminal.',
    explanation:
        'A neutral viral moment gives the city texture without moving a hidden score.',
    markerType: CityMapMarkerType.transport,
    district: CitySimulationDistrict.harborDistrict,
    severity: CityEventSeverity.ambient,
    preferredLocationIds: ['transport_terminal'],
    indicatorEffects: {},
  ),
];
