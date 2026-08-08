import '../../domain/models/candidate_biography.dart';
import '../../domain/models/city_problem.dart';

const bayhavenCandidateBiographies = <String, CandidateBiography>{
  'maya_vargas': CandidateBiography(
    candidateId: 'maya_vargas',
    birthYear: 1982,
    occupation: 'Public-health administrator',
    education: [
      'B.S. Community Health, Bayhaven State University',
      'Master of Public Administration, St. Aurelia College',
    ],
    currentPosition: 'Mayoral candidate; former South Point Health Director',
    publicServiceStartYear: 2007,
    hometown: 'South Point, Bayhaven',
    previousPositions: [
      'Community health officer',
      'District emergency-care coordinator',
      'South Point Health Director',
    ],
    summary:
        'Maya Vargas is a public-health administrator known for mobile-clinic pilots and crisis communication. Her mayoral campaign emphasizes neighborhood care, while its funding assumptions and medical-supplier donations have drawn scrutiny.',
    informationFootprint: CandidateInformationFootprint.extensive,
    timeline: [
      CandidateLifeEvent(
        id: 'maya_education_2004',
        year: 2004,
        type: CandidateHistoryEventType.education,
        title: 'Graduated in community health',
        summary: 'Completed her undergraduate degree in Bayhaven.',
        details:
            'Vargas studied community health and completed field placements in South Point clinics.',
        evidenceIds: ['maya_profile'],
        relatedIssueFamilies: [CityIssueFamily.healthcareCapacity],
        publicVisibility: CandidatePublicVisibility.local,
      ),
      CandidateLifeEvent(
        id: 'maya_health_office_2007',
        year: 2007,
        type: CandidateHistoryEventType.publicService,
        title: 'Joined the City Health Office',
        summary: 'Began as a community health officer.',
        details:
            'Her early assignments covered vaccination outreach and neighborhood health surveys.',
        evidenceIds: ['maya_profile'],
        relatedIssueFamilies: [CityIssueFamily.healthcareCapacity],
        publicVisibility: CandidatePublicVisibility.local,
      ),
      CandidateLifeEvent(
        id: 'maya_emergency_2014',
        year: 2014,
        type: CandidateHistoryEventType.appointment,
        title: 'Appointed emergency-care coordinator',
        summary:
            'Coordinated district clinic response during a respiratory outbreak.',
        details:
            'Colleagues credited Vargas with organizing late-night care, although the response relied heavily on temporary staffing.',
        evidenceIds: ['maya_profile', 'maya_publicRecord'],
        relatedIssueFamilies: [CityIssueFamily.healthcareCapacity],
        publicVisibility: CandidatePublicVisibility.citywide,
      ),
      CandidateLifeEvent(
        id: 'maya_director_2017',
        year: 2017,
        type: CandidateHistoryEventType.appointment,
        title: 'Became South Point Health Director',
        summary:
            'Oversaw neighborhood clinics and community-care partnerships.',
        details:
            'Her office managed clinic staffing, preventive-care programs, and emergency coordination in South Point.',
        evidenceIds: ['maya_profile'],
        relatedIssueFamilies: [CityIssueFamily.healthcareCapacity],
        publicVisibility: CandidatePublicVisibility.citywide,
      ),
      CandidateLifeEvent(
        id: 'maya_mobile_clinics_2022',
        year: 2022,
        type: CandidateHistoryEventType.project,
        title: 'Led a mobile-clinic pilot',
        summary: 'Two pilot districts recorded shorter clinic waits.',
        details:
            'The pilot used two mobile units and a one-time grant. It improved access where deployed but did not establish permanent citywide funding.',
        evidenceIds: ['maya_publicRecord', 'maya_budgetDocument'],
        relatedIssueFamilies: [
          CityIssueFamily.healthcareCapacity,
          CityIssueFamily.employmentQuality,
        ],
        publicVisibility: CandidatePublicVisibility.prominent,
      ),
      CandidateLifeEvent(
        id: 'maya_donor_questions_2024',
        year: 2024,
        type: CandidateHistoryEventType.controversy,
        title: 'Medical-supplier donations questioned',
        summary:
            'Campaign filings showed support from a potential city supplier.',
        details:
            'The relationship is documented. No improper contract award has been established, and Vargas proposed an open-bidding portal in response.',
        evidenceIds: ['maya_controversy', 'maya_publicRecord'],
        relatedIssueFamilies: [CityIssueFamily.corruptionPublicFunds],
        publicVisibility: CandidatePublicVisibility.prominent,
      ),
    ],
    sections: [
      CandidateBiographySection(
        id: 'maya_early_life',
        title: 'Early life and education',
        statements: [
          CandidateBiographyStatement(
            id: 'maya_early_south_point',
            text:
                'Vargas was raised in South Point and later studied community health at Bayhaven State University.',
            evidenceIds: ['maya_profile'],
          ),
          CandidateBiographyStatement(
            id: 'maya_mpa',
            text:
                'She later completed public-administration training while working in the city health system.',
            evidenceIds: ['maya_profile'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'maya_career',
        title: 'Public-health career',
        statements: [
          CandidateBiographyStatement(
            id: 'maya_joined_office',
            text:
                'Vargas joined the City Health Office in 2007 and held community-health and emergency-care assignments before becoming South Point Health Director.',
            evidenceIds: ['maya_profile'],
          ),
          CandidateBiographyStatement(
            id: 'maya_crisis_work',
            text:
                'Her public reputation grew during a respiratory outbreak, when she coordinated extended clinic hours and temporary care teams.',
            evidenceIds: ['maya_profile', 'maya_publicRecord'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'maya_projects',
        title: 'Major projects and public record',
        statements: [
          CandidateBiographyStatement(
            id: 'maya_pilot_result',
            text:
                'A mobile-clinic pilot under Vargas reduced recorded waiting times in two districts.',
            evidenceIds: ['maya_publicRecord'],
          ),
          CandidateBiographyStatement(
            id: 'maya_pilot_limit',
            text:
                'The pilot depended on a one-time grant, leaving questions about whether the program could be expanded without new recurring revenue.',
            evidenceIds: ['maya_publicRecord', 'maya_budgetDocument'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'maya_positions',
        title: 'Political positions',
        statements: [
          CandidateBiographyStatement(
            id: 'maya_health_position',
            text:
                'Her campaign prioritizes longer clinic hours, mobile care, health apprenticeships, and phased replacement of high-risk water lines.',
            evidenceIds: ['maya_platform', 'maya_debateAnswer'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'maya_controversies',
        title: 'Campaign finance questions',
        statements: [
          CandidateBiographyStatement(
            id: 'maya_donor_relationship',
            text:
                'Vargas faced criticism after a medical distributor that could bid on clinic contracts contributed to her campaign.',
            evidenceIds: ['maya_controversy'],
          ),
          CandidateBiographyStatement(
            id: 'maya_donor_response',
            text:
                'She denied promising favorable treatment and proposed published competitive bidding; the proposal remains a campaign commitment rather than an implemented safeguard.',
            evidenceIds: ['maya_controversy', 'maya_platform'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'maya_electoral_history',
        title: 'Electoral history',
        statements: [
          CandidateBiographyStatement(
            id: 'maya_first_mayoral_campaign',
            text:
                'The current election is Vargas’s first campaign for mayor after a career in appointed health-administration roles.',
            evidenceIds: ['maya_profile'],
          ),
        ],
      ),
    ],
  ),
  'julian_pratt': CandidateBiography(
    candidateId: 'julian_pratt',
    birthYear: 1975,
    occupation: 'Logistics executive and development-board chair',
    education: [
      'B.S. Business Logistics, North Coast College',
      'Executive certificate in urban development finance',
    ],
    currentPosition: 'Mayoral candidate; former Development Board chair',
    publicServiceStartYear: 2012,
    hometown: 'Harbor District, Bayhaven',
    previousPositions: [
      'Operations manager, Pratt Coastal Logistics',
      'Chief executive, Harborline Distribution',
      'Chair, Bayhaven Development Board',
    ],
    summary:
        'Julian Pratt is a logistics executive who entered public life through the Bayhaven Development Board. Supporters cite fast project delivery and job creation; critics focus on temporary employment figures, procurement disclosure, and limited climate planning.',
    informationFootprint: CandidateInformationFootprint.overexposed,
    timeline: [
      CandidateLifeEvent(
        id: 'julian_logistics_1998',
        year: 1998,
        type: CandidateHistoryEventType.employment,
        title: 'Entered the logistics industry',
        summary: 'Began managing warehouse and port-delivery operations.',
        details:
            'Pratt built his career around high-volume distribution and rapid project schedules.',
        evidenceIds: ['julian_profile'],
        relatedIssueFamilies: [CityIssueFamily.employmentQuality],
        publicVisibility: CandidatePublicVisibility.local,
      ),
      CandidateLifeEvent(
        id: 'julian_executive_2006',
        year: 2006,
        type: CandidateHistoryEventType.businessActivity,
        title: 'Became Harborline Distribution executive',
        summary: 'Expanded regional shipping and warehouse contracts.',
        details:
            'His business profile emphasized deadlines, incentives, and private-sector partnerships.',
        evidenceIds: ['julian_profile'],
        relatedIssueFamilies: [
          CityIssueFamily.employmentQuality,
          CityIssueFamily.trafficTransport,
        ],
        publicVisibility: CandidatePublicVisibility.citywide,
      ),
      CandidateLifeEvent(
        id: 'julian_board_2012',
        year: 2012,
        type: CandidateHistoryEventType.appointment,
        title: 'Appointed to the Development Board',
        summary: 'Joined the body responsible for major development approvals.',
        details:
            'Pratt promoted tax incentives and expedited review for logistics and manufacturing projects.',
        evidenceIds: ['julian_profile'],
        relatedIssueFamilies: [CityIssueFamily.governmentServices],
        publicVisibility: CandidatePublicVisibility.citywide,
      ),
      CandidateLifeEvent(
        id: 'julian_market_project_2018',
        year: 2018,
        type: CandidateHistoryEventType.project,
        title: 'Supervised the North Avenue redevelopment',
        summary: 'The project opened on schedule and increased nearby trade.',
        details:
            'Records confirm timely completion. Employment reports combine permanent, seasonal, and project-limited positions.',
        evidenceIds: ['julian_publicRecord', 'julian_factCheck'],
        relatedIssueFamilies: [
          CityIssueFamily.employmentQuality,
          CityIssueFamily.unfinishedRoads,
        ],
        publicVisibility: CandidatePublicVisibility.prominent,
      ),
      CandidateLifeEvent(
        id: 'julian_board_chair_2020',
        year: 2020,
        type: CandidateHistoryEventType.appointment,
        title: 'Chosen as Development Board chair',
        summary: 'Led approvals during the city’s employment recovery.',
        details:
            'The board accelerated several projects and deferred part of their maintenance cost to later budgets.',
        evidenceIds: ['julian_publicRecord', 'julian_budgetDocument'],
        relatedIssueFamilies: [
          CityIssueFamily.employmentQuality,
          CityIssueFamily.corruptionPublicFunds,
        ],
        publicVisibility: CandidatePublicVisibility.prominent,
      ),
      CandidateLifeEvent(
        id: 'julian_contract_inquiry_2023',
        year: 2023,
        type: CandidateHistoryEventType.controversy,
        title: 'Subcontract disclosure questioned',
        summary:
            'A family-linked firm appeared in unpublished selection notes.',
        details:
            'The subcontract is documented, but the available record does not establish that Pratt personally ordered the award.',
        evidenceIds: ['julian_controversy'],
        relatedIssueFamilies: [CityIssueFamily.corruptionPublicFunds],
        publicVisibility: CandidatePublicVisibility.prominent,
      ),
      CandidateLifeEvent(
        id: 'julian_mayoral_run_2026',
        year: 2026,
        type: CandidateHistoryEventType.election,
        title: 'Entered the mayoral race',
        summary: 'Campaigns on rapid hiring and private delivery partnerships.',
        details:
            'His campaign foregrounds completed projects and argues that economic growth should finance city services.',
        evidenceIds: ['julian_platform', 'julian_campaignAd'],
        relatedIssueFamilies: [CityIssueFamily.employmentQuality],
        publicVisibility: CandidatePublicVisibility.prominent,
      ),
    ],
    sections: [
      CandidateBiographySection(
        id: 'julian_early_life',
        title: 'Early life and education',
        statements: [
          CandidateBiographyStatement(
            id: 'julian_harbor_upbringing',
            text:
                'Pratt grew up in the Harbor District and studied business logistics before entering warehouse operations.',
            evidenceIds: ['julian_profile'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'julian_business_career',
        title: 'Business career',
        statements: [
          CandidateBiographyStatement(
            id: 'julian_distribution_career',
            text:
                'He advanced through regional distribution companies and became known for compressed construction and delivery schedules.',
            evidenceIds: ['julian_profile', 'julian_publicRecord'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'julian_politics',
        title: 'Entry into public service',
        statements: [
          CandidateBiographyStatement(
            id: 'julian_board_entry',
            text:
                'Pratt entered public service through an appointment to the Development Board and later served as its chair.',
            evidenceIds: ['julian_profile'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'julian_projects',
        title: 'Development projects',
        statements: [
          CandidateBiographyStatement(
            id: 'julian_delivery_record',
            text:
                'Two prominent projects overseen by the board opened on schedule, including the North Avenue redevelopment.',
            evidenceIds: ['julian_publicRecord'],
          ),
          CandidateBiographyStatement(
            id: 'julian_job_duration',
            text:
                'Labor filings support substantial hiring but show that many positions were seasonal or ended after subsidy periods.',
            evidenceIds: ['julian_publicRecord', 'julian_factCheck'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'julian_positions',
        title: 'Political positions',
        statements: [
          CandidateBiographyStatement(
            id: 'julian_growth_position',
            text:
                'Pratt favors manufacturing incentives, expedited development, and private operators for major utility work.',
            evidenceIds: ['julian_platform', 'julian_debateAnswer'],
          ),
          CandidateBiographyStatement(
            id: 'julian_budget_tradeoff',
            text:
                'Independent review finds identifiable revenue sources but warns that later budgets would inherit maintenance obligations.',
            evidenceIds: ['julian_budgetDocument'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'julian_controversies',
        title: 'Procurement controversy',
        statements: [
          CandidateBiographyStatement(
            id: 'julian_family_contractor',
            text:
                'A contractor connected to Pratt’s family received subcontracted work while he chaired the Development Board.',
            evidenceIds: ['julian_controversy'],
          ),
          CandidateBiographyStatement(
            id: 'julian_missing_notes',
            text:
                'Selection notes were not published. Pratt says the board followed the rules then in force; the public record does not resolve whether he influenced the award.',
            evidenceIds: ['julian_controversy', 'julian_publicRecord'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'julian_electoral_history',
        title: 'Electoral history',
        statements: [
          CandidateBiographyStatement(
            id: 'julian_first_citywide_race',
            text:
                'The current mayoral campaign is Pratt’s first citywide election after serving in appointed development roles.',
            evidenceIds: ['julian_profile'],
          ),
        ],
      ),
    ],
  ),
  'victor_chen': CandidateBiography(
    candidateId: 'victor_chen',
    birthYear: 1979,
    occupation: 'Civil engineer and infrastructure auditor',
    education: [
      'B.S. Civil Engineering, Bayhaven Polytechnic Institute',
      'Certificate in public procurement and infrastructure audit',
    ],
    currentPosition: 'Mayoral candidate; former Water Authority planner',
    publicServiceStartYear: 2003,
    hometown: 'Riverside, Bayhaven',
    previousPositions: [
      'Municipal drainage engineer',
      'Water Authority capital planner',
      'Infrastructure compliance auditor',
    ],
    summary:
        'Victor Chen is a civil engineer and former Water Authority planner associated with detailed audits and maintenance planning. His record is considered transparent, while delayed projects and a small political coalition remain central questions.',
    informationFootprint: CandidateInformationFootprint.normal,
    timeline: [
      CandidateLifeEvent(
        id: 'victor_engineering_2001',
        year: 2001,
        type: CandidateHistoryEventType.education,
        title: 'Completed civil-engineering degree',
        summary: 'Focused on water and drainage systems.',
        details:
            'Chen’s undergraduate work examined pressure loss and drainage capacity in dense neighborhoods.',
        evidenceIds: ['victor_profile'],
        relatedIssueFamilies: [
          CityIssueFamily.waterSupply,
          CityIssueFamily.floodingDrainage,
        ],
        publicVisibility: CandidatePublicVisibility.obscure,
      ),
      CandidateLifeEvent(
        id: 'victor_city_engineer_2003',
        year: 2003,
        type: CandidateHistoryEventType.publicService,
        title: 'Joined municipal engineering service',
        summary: 'Worked on drainage inspections and repair plans.',
        details:
            'His early work concentrated on maintenance surveys rather than large new construction.',
        evidenceIds: ['victor_profile'],
        relatedIssueFamilies: [CityIssueFamily.floodingDrainage],
        publicVisibility: CandidatePublicVisibility.local,
      ),
      CandidateLifeEvent(
        id: 'victor_water_planner_2010',
        year: 2010,
        type: CandidateHistoryEventType.appointment,
        title: 'Became Water Authority capital planner',
        summary: 'Prepared replacement schedules for aging water lines.',
        details:
            'Chen promoted risk-based sequencing and dedicated maintenance reserves.',
        evidenceIds: ['victor_profile', 'victor_publicRecord'],
        relatedIssueFamilies: [CityIssueFamily.waterSupply],
        publicVisibility: CandidatePublicVisibility.citywide,
      ),
      CandidateLifeEvent(
        id: 'victor_audit_reform_2016',
        year: 2016,
        type: CandidateHistoryEventType.accomplishment,
        title: 'Introduced standardized project reporting',
        summary: 'Audit reviews found more consistent cost and delay records.',
        details:
            'The reporting system made project delays visible but did not give Chen authority to approve stalled funding.',
        evidenceIds: ['victor_publicRecord'],
        relatedIssueFamilies: [
          CityIssueFamily.corruptionPublicFunds,
          CityIssueFamily.unfinishedRoads,
        ],
        publicVisibility: CandidatePublicVisibility.citywide,
      ),
      CandidateLifeEvent(
        id: 'victor_delayed_upgrades_2021',
        year: 2021,
        type: CandidateHistoryEventType.failure,
        title: 'Two upgrades missed their schedules',
        summary:
            'Council votes delayed projects despite accurate planning reports.',
        details:
            'The record supports Chen’s reporting but raises questions about whether he can build enough political support to deliver a citywide program.',
        evidenceIds: ['victor_publicRecord', 'victor_debateAnswer'],
        relatedIssueFamilies: [
          CityIssueFamily.waterSupply,
          CityIssueFamily.unfinishedRoads,
        ],
        publicVisibility: CandidatePublicVisibility.prominent,
      ),
      CandidateLifeEvent(
        id: 'victor_dam_claim_2024',
        year: 2024,
        type: CandidateHistoryEventType.controversy,
        title: 'Dam-design allegation circulated',
        summary: 'A viral post wrongly described Chen as the project designer.',
        details:
            'Records show that Chen reviewed compliance documents but did not design the dam.',
        evidenceIds: ['victor_socialPost', 'victor_factCheck'],
        relatedIssueFamilies: [CityIssueFamily.floodingDrainage],
        publicVisibility: CandidatePublicVisibility.prominent,
      ),
    ],
    sections: [
      CandidateBiographySection(
        id: 'victor_education',
        title: 'Education and early career',
        statements: [
          CandidateBiographyStatement(
            id: 'victor_engineering_focus',
            text:
                'Chen studied civil engineering and began his career inspecting drainage and municipal repair work.',
            evidenceIds: ['victor_profile'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'victor_water_career',
        title: 'Water Authority career',
        statements: [
          CandidateBiographyStatement(
            id: 'victor_planning_role',
            text:
                'As a Water Authority planner, Chen prepared risk-based replacement schedules and advocated maintenance reserves.',
            evidenceIds: ['victor_profile', 'victor_budgetDocument'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'victor_record',
        title: 'Public-service record',
        statements: [
          CandidateBiographyStatement(
            id: 'victor_reporting_record',
            text:
                'Independent audits found Chen’s project reporting accurate and his cost records consistent.',
            evidenceIds: ['victor_publicRecord'],
          ),
          CandidateBiographyStatement(
            id: 'victor_delay_record',
            text:
                'Two upgrades were nevertheless delayed after council funding votes stalled, creating debate over the difference between a sound plan and political delivery.',
            evidenceIds: ['victor_publicRecord', 'victor_debateAnswer'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'victor_positions',
        title: 'Political positions',
        statements: [
          CandidateBiographyStatement(
            id: 'victor_contract_position',
            text:
                'Chen supports publication of infrastructure contracts, dedicated maintenance funding, and local training for long-term repair work.',
            evidenceIds: ['victor_platform', 'victor_budgetDocument'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'victor_controversy',
        title: 'Dam-design allegation',
        statements: [
          CandidateBiographyStatement(
            id: 'victor_dam_role',
            text:
                'A widely shared post blamed Chen for a failed dam design, although public records place him in a later compliance-review role rather than the design team.',
            evidenceIds: ['victor_socialPost', 'victor_factCheck'],
          ),
        ],
      ),
      CandidateBiographySection(
        id: 'victor_electoral_history',
        title: 'Electoral history',
        statements: [
          CandidateBiographyStatement(
            id: 'victor_first_election',
            text:
                'Chen entered the current mayoral race without previous elected office and with a comparatively small council bloc.',
            evidenceIds: ['victor_profile', 'victor_debateAnswer'],
          ),
        ],
      ),
    ],
  ),
};

const bayhavenCandidatePromises = <CandidatePromise>[
  CandidatePromise(
    id: 'promise_maya_clinic_access',
    candidateId: 'maya_vargas',
    title: 'Care in every district',
    candidateWording:
        'Extend clinic hours, restore mobile units, and train paid health apprentices.',
    approach:
        'Phase neighborhood service expansion around staffing and available recurring revenue.',
    complexity: CandidatePromiseComplexity.multiAgency,
    relatedIssueFamilies: [
      CityIssueFamily.healthcareCapacity,
      CityIssueFamily.employmentQuality,
    ],
    evidenceIds: ['maya_platform', 'maya_budgetDocument'],
    relatedHistoryEventIds: ['maya_mobile_clinics_2022'],
  ),
  CandidatePromise(
    id: 'promise_maya_water_testing',
    candidateId: 'maya_vargas',
    title: 'Test first, repair by risk',
    candidateWording:
        'Deploy mobile testing teams and replace the highest-risk water lines first.',
    approach:
        'Use street-level testing to prioritize phased capital repairs and public-health warnings.',
    complexity: CandidatePromiseComplexity.capitalProject,
    relatedIssueFamilies: [CityIssueFamily.waterSupply],
    evidenceIds: ['maya_platform', 'maya_debateAnswer'],
    relatedHistoryEventIds: ['maya_emergency_2014'],
  ),
  CandidatePromise(
    id: 'promise_maya_open_contracts',
    candidateId: 'maya_vargas',
    title: 'Open health contracting',
    candidateWording:
        'Publish competitive bids and awards through a public procurement portal.',
    approach:
        'Add disclosure rules around suppliers that may benefit from health expansion.',
    complexity: CandidatePromiseComplexity.structuralReform,
    relatedIssueFamilies: [CityIssueFamily.corruptionPublicFunds],
    evidenceIds: ['maya_platform', 'maya_controversy'],
    relatedHistoryEventIds: ['maya_donor_questions_2024'],
  ),
  CandidatePromise(
    id: 'promise_julian_manufacturing',
    candidateId: 'julian_pratt',
    title: 'Manufacturing jobs in the first quarter',
    candidateWording:
        'Offer time-limited incentives to employers that hire Bayhaven residents.',
    approach:
        'Use tax incentives and expedited approvals to bring participating employers online quickly.',
    complexity: CandidatePromiseComplexity.multiAgency,
    relatedIssueFamilies: [CityIssueFamily.employmentQuality],
    evidenceIds: ['julian_platform', 'julian_budgetDocument'],
    relatedHistoryEventIds: [
      'julian_market_project_2018',
      'julian_board_chair_2020',
    ],
  ),
  CandidatePromise(
    id: 'promise_julian_logistics_district',
    candidateId: 'julian_pratt',
    title: 'Fast-track a logistics and market district',
    candidateWording:
        'Complete permits and site work on a single public delivery schedule.',
    approach:
        'Centralize approvals and use contract milestones to reduce project delay.',
    complexity: CandidatePromiseComplexity.capitalProject,
    relatedIssueFamilies: [
      CityIssueFamily.unfinishedRoads,
      CityIssueFamily.trafficTransport,
      CityIssueFamily.governmentServices,
    ],
    evidenceIds: ['julian_platform', 'julian_publicRecord'],
    relatedHistoryEventIds: ['julian_market_project_2018'],
  ),
  CandidatePromise(
    id: 'promise_julian_private_water',
    candidateId: 'julian_pratt',
    title: 'Private operators for water repairs',
    candidateWording:
        'Bring qualified private operators in immediately to replace the worst lines.',
    approach:
        'Procure rapid repair capacity while shifting some maintenance obligations to contractors.',
    complexity: CandidatePromiseComplexity.capitalProject,
    relatedIssueFamilies: [
      CityIssueFamily.waterSupply,
      CityIssueFamily.corruptionPublicFunds,
    ],
    evidenceIds: ['julian_platform', 'julian_budgetDocument'],
    relatedHistoryEventIds: ['julian_contract_inquiry_2023'],
  ),
  CandidatePromise(
    id: 'promise_victor_water_sequence',
    candidateId: 'victor_chen',
    title: 'Publish the water-repair sequence',
    candidateWording:
        'Map contamination and pressure loss, then publish which lines will be replaced first.',
    approach:
        'Use existing engineering data, emergency bypasses, and a funded maintenance reserve.',
    complexity: CandidatePromiseComplexity.capitalProject,
    relatedIssueFamilies: [
      CityIssueFamily.waterSupply,
      CityIssueFamily.floodingDrainage,
    ],
    evidenceIds: ['victor_platform', 'victor_budgetDocument'],
    relatedHistoryEventIds: ['victor_water_planner_2010'],
  ),
  CandidatePromise(
    id: 'promise_victor_open_contracts',
    candidateId: 'victor_chen',
    title: 'Publish every infrastructure contract',
    candidateWording:
        'Make bids, awards, milestones, and labor targets visible to the public.',
    approach:
        'Standardize contract reporting and expose delay or cost changes as they happen.',
    complexity: CandidatePromiseComplexity.structuralReform,
    relatedIssueFamilies: [
      CityIssueFamily.corruptionPublicFunds,
      CityIssueFamily.unfinishedRoads,
    ],
    evidenceIds: ['victor_platform', 'victor_publicRecord'],
    relatedHistoryEventIds: ['victor_audit_reform_2016'],
  ),
  CandidatePromise(
    id: 'promise_victor_repair_training',
    candidateId: 'victor_chen',
    title: 'Train residents for long-term repair work',
    candidateWording:
        'Put local labor targets into infrastructure contracts and train crews for maintenance.',
    approach:
        'Tie apprenticeship slots to funded repair packages rather than temporary hiring totals.',
    complexity: CandidatePromiseComplexity.multiAgency,
    relatedIssueFamilies: [CityIssueFamily.employmentQuality],
    evidenceIds: ['victor_platform', 'victor_budgetDocument'],
    relatedHistoryEventIds: ['victor_audit_reform_2016'],
  ),
];

const bayhavenStatementComparisons = <CandidateStatementComparison>[
  CandidateStatementComparison(
    id: 'comparison_maya_scale',
    candidateId: 'maya_vargas',
    thenYear: 2022,
    thenStatement:
        'The mobile-clinic pilot should remain limited until recurring funding is secured.',
    nowYear: 2026,
    nowStatement:
        'Care cannot wait for a perfect budget; the citywide rollout should begin immediately.',
    context:
        'The earlier statement concerned a grant-funded pilot. The campaign now proposes a phased citywide program tied to projected business-tax revenue. The position may reflect changed urgency, but the recurring funding gap remains unresolved.',
    evidenceIds: ['maya_publicRecord', 'maya_budgetDocument'],
    relatedPromiseId: 'promise_maya_clinic_access',
  ),
  CandidateStatementComparison(
    id: 'comparison_julian_incentives',
    candidateId: 'julian_pratt',
    thenYear: 2019,
    thenStatement:
        'Public incentives should end once a development project reaches normal operations.',
    nowYear: 2026,
    nowStatement:
        'Strategic employers may need renewed incentives while Bayhaven rebuilds its job base.',
    context:
        'Pratt argues that current closures justify a different policy. Labor and budget records show real job creation alongside seasonal work and later maintenance exposure; they do not by themselves establish whether renewed incentives are warranted.',
    evidenceIds: ['julian_publicRecord', 'julian_budgetDocument'],
    relatedPromiseId: 'promise_julian_manufacturing',
  ),
  CandidateStatementComparison(
    id: 'comparison_victor_coalition',
    candidateId: 'victor_chen',
    thenYear: 2021,
    thenStatement:
        'An engineering schedule should not be rewritten to satisfy council politics.',
    nowYear: 2026,
    nowStatement:
        'A correct plan still needs a coalition, and the public should see every compromise required to fund it.',
    context:
        'Two upgrades were delayed after council votes stalled. Chen now describes coalition-building as necessary while promising to preserve public reporting of any changed schedule.',
    evidenceIds: ['victor_publicRecord', 'victor_debateAnswer'],
    relatedPromiseId: 'promise_victor_water_sequence',
  ),
];

const bayhavenCandidateInformationRelations = <CandidateInformationRelation>[
  CandidateInformationRelation(
    from: CandidateInformationReference(
      kind: CandidateInformationKind.promise,
      id: 'promise_maya_clinic_access',
    ),
    to: CandidateInformationReference(
      kind: CandidateInformationKind.historyEvent,
      id: 'maya_mobile_clinics_2022',
    ),
    type: CandidateRelationType.references,
    explanation: 'The clinic promise expands an earlier two-district pilot.',
  ),
  CandidateInformationRelation(
    from: CandidateInformationReference(
      kind: CandidateInformationKind.promise,
      id: 'promise_julian_manufacturing',
    ),
    to: CandidateInformationReference(
      kind: CandidateInformationKind.historyEvent,
      id: 'julian_market_project_2018',
    ),
    type: CandidateRelationType.addsContext,
    explanation:
        'The earlier project supports delivery claims but complicates permanent-job wording.',
  ),
  CandidateInformationRelation(
    from: CandidateInformationReference(
      kind: CandidateInformationKind.promise,
      id: 'promise_victor_open_contracts',
    ),
    to: CandidateInformationReference(
      kind: CandidateInformationKind.historyEvent,
      id: 'victor_audit_reform_2016',
    ),
    type: CandidateRelationType.supports,
    explanation:
        'The promise extends Chen’s earlier standardized reporting work.',
  ),
];
