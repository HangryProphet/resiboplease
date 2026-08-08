import '../../domain/models/candidate_experience.dart';
import '../../domain/models/city_problem.dart';
import 'bayhaven_candidate_biographies.dart';

const bayhavenCandidateExperience = CandidateExperienceCatalog(
  biographies: bayhavenCandidateBiographies,
  promises: bayhavenCandidatePromises,
  comparisons: bayhavenStatementComparisons,
  informationRelations: bayhavenCandidateInformationRelations,
  profiles: {
    'maya_vargas': CandidateExperienceProfile(
      candidateId: 'maya_vargas',
      identityKey: 'maya_vargas_001',
      portraitAssetKey: 'candidate_maya_vargas_neutral',
      publicIdentity: 'Former health administrator turned reform candidate',
      position: 'Mayor of Bayhaven',
      rhetoricalStyle: CandidateRhetoricalStyle.charismatic,
      qualityBand: CandidateQualityBand.compromised,
      questions: [
        CandidateQuestion(
          id: 'question_maya_clinic_budget',
          text: 'Where will the clinic expansion budget come from?',
          cityIssueId: 'clinic_overload',
          relatedEvidenceIds: ['maya_platform', 'maya_budgetDocument'],
        ),
        CandidateQuestion(
          id: 'question_maya_donors',
          text: 'Could medical suppliers influence future contracts?',
          cityIssueId: 'clinic_overload',
          relatedEvidenceIds: ['maya_controversy', 'maya_publicRecord'],
        ),
      ],
      pulse: [
        CandidateContentItem(
          id: 'pulse_maya_launch',
          candidateId: 'maya_vargas',
          type: CandidateContentType.publicEvent,
          headline: 'Vargas opens with a packed clinic rally',
          summary:
              'Her promise of neighborhood care draws the loudest launch crowd.',
          inspectBody:
              'Vargas introduced nurses and community volunteers who worked with her mobile clinic program. The event focused on long waits and medicine shortages rather than broad city policy.',
          deepDivePrompt:
              'Compare the rally claims with the public performance record.',
          source: 'Bayhaven Public Media',
          fictionalDate: 'Campaign Day 2',
          cityIssueId: 'clinic_overload',
          relatedEvidenceIds: ['maya_campaignAd', 'maya_publicRecord'],
          receiptKind: ReceiptKind.supportedClaim,
          keyFigures: ['2 pilot districts', '2 mobile units'],
          publicAttention: 88,
          media: CandidateMedia(
            assetKey: 'maya_clinic_rally',
            aspectRatio: 16 / 9,
            altText: 'Vargas speaking beside clinic workers',
            caption: 'Campaign launch photograph supplied to local media.',
            type: CandidateMediaType.image,
          ),
        ),
        CandidateContentItem(
          id: 'pulse_maya_volunteer',
          candidateId: 'maya_vargas',
          type: CandidateContentType.residentReaction,
          headline: 'A nurse remembers the mobile-clinic nights',
          summary:
              'A former colleague describes Vargas as calm during a difficult outbreak.',
          inspectBody:
              'The nurse credits Vargas with organizing late-night care when one district clinic closed. The story is personal testimony, not a complete review of the program.',
          deepDivePrompt:
              'Check whether the program continued after emergency grant funding ended.',
          source: 'Harbor Neighborhood Journal',
          fictionalDate: 'Campaign Day 5',
          cityIssueId: 'clinic_overload',
          relatedEvidenceIds: ['maya_profile', 'maya_publicRecord'],
          receiptKind: ReceiptKind.accomplishmentWithCost,
          missingContext: 'The pilot depended on a one-time grant.',
          publicAttention: 54,
          media: CandidateMedia(
            assetKey: 'maya_mobile_clinic_story',
            aspectRatio: 4 / 3,
            altText: 'A fictional nurse outside a mobile clinic',
            caption: 'Illustration slot for a resident interview.',
            type: CandidateMediaType.image,
          ),
        ),
        CandidateContentItem(
          id: 'pulse_maya_promise',
          candidateId: 'maya_vargas',
          type: CandidateContentType.campaignAd,
          headline: '“Care in every district” dominates the airwaves',
          summary:
              'The campaign promises longer clinic hours and paid health apprenticeships.',
          inspectBody:
              'The proposal would extend care quickly and train residents for support roles. Its first-year revenue assumptions depend on business taxes arriving on schedule.',
          deepDivePrompt: 'Open the platform and independent budget reading.',
          source: 'Vargas Campaign',
          fictionalDate: 'Campaign Day 8',
          cityIssueId: 'clinic_overload',
          relatedEvidenceIds: ['maya_platform', 'maya_budgetDocument'],
          receiptKind: ReceiptKind.promiseWithoutFunding,
          missingContext: 'The advertisement does not explain the funding gap.',
          publicAttention: 92,
          media: CandidateMedia(
            assetKey: 'maya_clinic_poster',
            aspectRatio: 1,
            altText: 'Campaign poster promising expanded clinics',
            caption: 'Paid campaign material.',
            type: CandidateMediaType.socialPost,
          ),
        ),
        CandidateContentItem(
          id: 'pulse_maya_donor',
          candidateId: 'maya_vargas',
          type: CandidateContentType.scandal,
          headline: 'Medical supplier donations raise contract questions',
          summary:
              'A distributor that may bid on city work donated to the campaign.',
          inspectBody:
              'Donation filings establish the financial relationship. No improper contract award is documented, but the supplier could benefit from clinic expansion.',
          deepDivePrompt:
              'Inspect the controversy file before deciding how much the relationship matters.',
          source: 'The Bayhaven Beacon',
          fictionalDate: 'Campaign Day 12',
          cityIssueId: 'clinic_overload',
          relatedEvidenceIds: ['maya_controversy'],
          receiptKind: ReceiptKind.unresolvedAllegation,
          candidateResponse:
              'All contracts will use published competitive bidding.',
          publicAttention: 84,
          media: CandidateMedia(
            assetKey: 'maya_donor_network',
            aspectRatio: 16 / 9,
            altText: 'Diagram placeholder connecting a donor and campaign',
            caption:
                'Network graphic prepared from fictional donation filings.',
            type: CandidateMediaType.document,
          ),
        ),
        CandidateContentItem(
          id: 'pulse_maya_defense',
          candidateId: 'maya_vargas',
          type: CandidateContentType.statement,
          headline: 'Vargas promises an open-contract rule',
          summary:
              'She answers donor criticism with a proposed public bidding portal.',
          inspectBody:
              'The response addresses future procurement but does not remove the donor relationship. The portal is a campaign promise and has not yet been implemented.',
          deepDivePrompt:
              'Compare the defense with the original allegation and platform.',
          source: 'Vargas Press Desk',
          fictionalDate: 'Campaign Day 13',
          cityIssueId: 'clinic_overload',
          relatedEvidenceIds: ['maya_controversy', 'maya_platform'],
          receiptKind: ReceiptKind.partiallySupported,
          publicAttention: 67,
        ),
        CandidateContentItem(
          id: 'pulse_maya_correction',
          candidateId: 'maya_vargas',
          type: CandidateContentType.factCheckAlert,
          headline: 'Fact-check: twelve clinics were not built',
          summary:
              'The viral construction claim confuses two mobile units with twelve clinics.',
          inspectBody:
              'Vargas coordinated two mobile units and clinic partnerships. Supporters expanded that record into a false construction total that the campaign did not originally publish.',
          deepDivePrompt:
              'Read the original post and the independent fact-check together.',
          source: 'Bayhaven Fact Desk',
          fictionalDate: 'Campaign Day 16',
          cityIssueId: 'clinic_overload',
          relatedEvidenceIds: ['maya_socialPost', 'maya_factCheck'],
          receiptKind: ReceiptKind.debateVersusFactCheck,
          publicAttention: 79,
        ),
      ],
      relations: [
        EvidenceRelation(
          fromEvidenceId: 'maya_socialPost',
          toEvidenceId: 'maya_factCheck',
          type: EvidenceRelationType.corrects,
          explanation:
              'The fact-check corrects the viral clinic-construction total.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'maya_platform',
          toEvidenceId: 'maya_budgetDocument',
          type: EvidenceRelationType.exposesMissingInformation,
          explanation:
              'The budget reading identifies the platform funding gap.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'maya_campaignAd',
          toEvidenceId: 'maya_publicRecord',
          type: EvidenceRelationType.addsContext,
          explanation:
              'The public record narrows the advertisement’s broad success claim.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'maya_controversy',
          toEvidenceId: 'maya_publicRecord',
          type: EvidenceRelationType.references,
          explanation:
              'Procurement records provide context for the donor concern.',
        ),
      ],
      evidenceCosts: {
        'maya_profile': 0,
        'maya_platform': 0,
        'maya_campaignAd': 0,
        'maya_socialPost': 0,
        'maya_publicRecord': 1,
        'maya_budgetDocument': 1,
        'maya_factCheck': 1,
        'maya_controversy': 2,
        'maya_debateAnswer': 1,
      },
    ),
    'julian_pratt': CandidateExperienceProfile(
      candidateId: 'julian_pratt',
      identityKey: 'julian_pratt_001',
      portraitAssetKey: 'candidate_julian_pratt_neutral',
      publicIdentity: 'Business executive promising rapid job creation',
      position: 'Mayor of Bayhaven',
      rhetoricalStyle: CandidateRhetoricalStyle.aggressive,
      qualityBand: CandidateQualityBand.dangerous,
      questions: [
        CandidateQuestion(
          id: 'question_julian_jobs',
          text: 'How many of the promised jobs would remain after subsidies?',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['julian_publicRecord', 'julian_factCheck'],
        ),
        CandidateQuestion(
          id: 'question_julian_contracts',
          text: 'Why were family-linked subcontract notes not published?',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['julian_controversy'],
        ),
      ],
      pulse: [
        CandidateContentItem(
          id: 'pulse_julian_launch',
          candidateId: 'julian_pratt',
          type: CandidateContentType.campaignAd,
          headline: 'Pratt promises to put Bayhaven back to work',
          summary:
              'A fast-moving launch ad highlights factories, markets, and completed projects.',
          inspectBody:
              'Pratt presents a detailed hiring-incentive plan and his record of finishing two development projects on schedule. The advertisement treats temporary and permanent work as one total.',
          deepDivePrompt:
              'Compare the ad with labor filings and the performance record.',
          source: 'Pratt Campaign',
          fictionalDate: 'Campaign Day 1',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['julian_campaignAd', 'julian_publicRecord'],
          receiptKind: ReceiptKind.accomplishmentWithCost,
          keyFigures: ['2 projects on schedule'],
          publicAttention: 94,
          media: CandidateMedia(
            assetKey: 'julian_jobs_launch',
            aspectRatio: 16 / 9,
            altText: 'Pratt speaking in front of a factory crowd',
            caption: 'Campaign launch image slot.',
            type: CandidateMediaType.image,
          ),
        ),
        CandidateContentItem(
          id: 'pulse_julian_worker',
          candidateId: 'julian_pratt',
          type: CandidateContentType.residentReaction,
          headline: 'A market vendor remembers a project arriving on time',
          summary:
              'One completed logistics site brought customers during a difficult season.',
          inspectBody:
              'The vendor describes a real short-term improvement around the site. The account does not establish whether the subsidized jobs remained after the project period.',
          deepDivePrompt: 'Check the public record for job-retention results.',
          source: 'Bayhaven Street Voices',
          fictionalDate: 'Campaign Day 4',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['julian_publicRecord'],
          receiptKind: ReceiptKind.partiallySupported,
          publicAttention: 61,
        ),
        CandidateContentItem(
          id: 'pulse_julian_promise',
          candidateId: 'julian_pratt',
          type: CandidateContentType.speech,
          headline: 'Manufacturing incentives promised in the first month',
          summary:
              'Pratt says employers will begin hiring before the next quarter.',
          inspectBody:
              'The plan identifies participating industries and tax incentives. Maintenance costs and the length of employer commitments are less clear.',
          deepDivePrompt: 'Open the platform and independent budget reading.',
          source: 'Forward Bayhaven Rally',
          fictionalDate: 'Campaign Day 7',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['julian_platform', 'julian_budgetDocument'],
          receiptKind: ReceiptKind.promiseWithoutFunding,
          publicAttention: 89,
        ),
        CandidateContentItem(
          id: 'pulse_julian_contract',
          candidateId: 'julian_pratt',
          type: CandidateContentType.scandal,
          headline:
              'Unpublished subcontract notes involve a family-linked firm',
          summary:
              'A contractor connected to Pratt’s family received work under his board.',
          inspectBody:
              'The subcontract existed and the selection notes were not published. The available record does not prove that Pratt personally directed the award.',
          deepDivePrompt: 'Spend time on the unresolved procurement file.',
          source: 'The Bayhaven Beacon',
          fictionalDate: 'Campaign Day 11',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['julian_controversy'],
          receiptKind: ReceiptKind.unresolvedAllegation,
          candidateResponse:
              'The board followed the procurement rules in force at the time.',
          publicAttention: 91,
          media: CandidateMedia(
            assetKey: 'julian_contract_files',
            aspectRatio: 4 / 3,
            altText: 'Stack of fictional subcontract records',
            caption: 'Document illustration slot.',
            type: CandidateMediaType.document,
          ),
        ),
        CandidateContentItem(
          id: 'pulse_julian_defense',
          candidateId: 'julian_pratt',
          type: CandidateContentType.statement,
          headline: 'Pratt calls the contract story “old political theater”',
          summary:
              'He points to projects delivered on time and denies directing awards.',
          inspectBody:
              'The defense accurately cites project completion. It does not answer why the selection notes were unavailable for public review.',
          deepDivePrompt:
              'Compare delivery evidence with the transparency question.',
          source: 'Pratt Press Desk',
          fictionalDate: 'Campaign Day 12',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['julian_publicRecord', 'julian_controversy'],
          receiptKind: ReceiptKind.statementVersusRecord,
          publicAttention: 82,
        ),
        CandidateContentItem(
          id: 'pulse_julian_jobs_check',
          candidateId: 'julian_pratt',
          type: CandidateContentType.factCheckAlert,
          headline: 'Job total is real, but “permanent” is not',
          summary:
              'Labor filings show that many celebrated positions were seasonal.',
          inspectBody:
              'The projects created employment and were completed on schedule. The campaign’s repeated permanent-job description leaves out how many positions ended with subsidies.',
          deepDivePrompt: 'Read the trending claim beside the fact-check.',
          source: 'Bayhaven Fact Desk',
          fictionalDate: 'Campaign Day 15',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['julian_socialPost', 'julian_factCheck'],
          receiptKind: ReceiptKind.missingContext,
          missingContext:
              'The filings do not show how many seasonal roles later became permanent.',
          publicAttention: 86,
        ),
      ],
      relations: [
        EvidenceRelation(
          fromEvidenceId: 'julian_socialPost',
          toEvidenceId: 'julian_factCheck',
          type: EvidenceRelationType.corrects,
          explanation:
              'The fact-check separates total positions from permanent jobs.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'julian_campaignAd',
          toEvidenceId: 'julian_publicRecord',
          type: EvidenceRelationType.addsContext,
          explanation:
              'The record confirms delivery but complicates the job claim.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'julian_platform',
          toEvidenceId: 'julian_budgetDocument',
          type: EvidenceRelationType.revealsConsequence,
          explanation: 'The budget shifts maintenance risk into later years.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'julian_controversy',
          toEvidenceId: 'julian_publicRecord',
          type: EvidenceRelationType.disputes,
          explanation:
              'Delivery records support competence but do not resolve transparency.',
        ),
      ],
      evidenceCosts: {
        'julian_profile': 0,
        'julian_platform': 0,
        'julian_campaignAd': 0,
        'julian_socialPost': 0,
        'julian_publicRecord': 1,
        'julian_budgetDocument': 1,
        'julian_factCheck': 1,
        'julian_controversy': 2,
        'julian_debateAnswer': 1,
      },
    ),
    'victor_chen': CandidateExperienceProfile(
      candidateId: 'victor_chen',
      identityKey: 'victor_chen_001',
      portraitAssetKey: 'candidate_victor_chen_neutral',
      publicIdentity: 'Quiet auditor campaigning on institutional repair',
      position: 'Mayor of Bayhaven',
      rhetoricalStyle: CandidateRhetoricalStyle.technical,
      qualityBand: CandidateQualityBand.strong,
      questions: [
        CandidateQuestion(
          id: 'question_victor_coalition',
          text: 'Can a small council bloc deliver the repair program?',
          cityIssueId: 'water_contamination',
          relatedEvidenceIds: ['victor_publicRecord', 'victor_debateAnswer'],
        ),
        CandidateQuestion(
          id: 'question_victor_jobs',
          text: 'How quickly would technical repair work create enough jobs?',
          cityIssueId: 'unemployment',
          relatedEvidenceIds: ['victor_platform', 'victor_budgetDocument'],
        ),
      ],
      pulse: [
        CandidateContentItem(
          id: 'pulse_victor_launch',
          candidateId: 'victor_chen',
          type: CandidateContentType.news,
          headline: 'Chen launches beside a leaking treatment line',
          summary:
              'The engineer presents a repair map instead of a traditional rally speech.',
          inspectBody:
              'Chen describes which lines should be replaced first and how every contract would be published. His launch draws a smaller crowd than his opponents.',
          deepDivePrompt:
              'Compare the repair sequence with the costed platform.',
          source: 'Bayhaven Public Media',
          fictionalDate: 'Campaign Day 3',
          cityIssueId: 'water_contamination',
          relatedEvidenceIds: ['victor_platform', 'victor_budgetDocument'],
          receiptKind: ReceiptKind.supportedClaim,
          publicAttention: 58,
          media: CandidateMedia(
            assetKey: 'victor_water_launch',
            aspectRatio: 16 / 9,
            altText: 'Chen pointing to a fictional water-system map',
            caption: 'News photograph slot from the launch event.',
            type: CandidateMediaType.image,
          ),
        ),
        CandidateContentItem(
          id: 'pulse_victor_auditor',
          candidateId: 'victor_chen',
          type: CandidateContentType.endorsement,
          headline: 'Retired auditor backs Chen’s recordkeeping',
          summary:
              'An independent reviewer recalls accurate reports even when projects were late.',
          inspectBody:
              'Audit findings support Chen’s transparency record. They also document two delayed upgrades, largely after council votes stalled.',
          deepDivePrompt:
              'Read the public record and decide how to weigh delay against disclosure.',
          source: 'Civic Ledger Interview',
          fictionalDate: 'Campaign Day 6',
          cityIssueId: 'water_contamination',
          relatedEvidenceIds: ['victor_publicRecord'],
          receiptKind: ReceiptKind.accomplishmentWithCost,
          publicAttention: 49,
        ),
        CandidateContentItem(
          id: 'pulse_victor_promise',
          candidateId: 'victor_chen',
          type: CandidateContentType.statement,
          headline: 'Every infrastructure contract would be public',
          summary:
              'Chen makes procurement transparency the center of his platform.',
          inspectBody:
              'The platform includes contract publication and maintenance reserves. It leaves less room for immediate employment subsidies.',
          deepDivePrompt:
              'Inspect both the platform and independent budget reading.',
          source: 'Common Ground Movement',
          fictionalDate: 'Campaign Day 9',
          cityIssueId: 'water_contamination',
          relatedEvidenceIds: ['victor_platform', 'victor_budgetDocument'],
          receiptKind: ReceiptKind.partiallySupported,
          publicAttention: 63,
        ),
        CandidateContentItem(
          id: 'pulse_victor_dam',
          candidateId: 'victor_chen',
          type: CandidateContentType.socialPost,
          headline: 'Viral post blames Chen for a failed dam design',
          summary:
              'The allegation spreads faster than the underlying safety record.',
          inspectBody:
              'Chen reviewed compliance documents but did not design the dam. The post uses a real project association to assign him a role he did not hold.',
          deepDivePrompt: 'Open the original post and independent correction.',
          source: 'HarborTalk Trending',
          fictionalDate: 'Campaign Day 11',
          cityIssueId: 'water_contamination',
          relatedEvidenceIds: ['victor_socialPost', 'victor_factCheck'],
          receiptKind: ReceiptKind.contradictedClaim,
          publicAttention: 90,
          media: CandidateMedia(
            assetKey: 'victor_dam_post',
            aspectRatio: 1,
            altText: 'Fictional viral post about a dam',
            caption: 'Social-post layout placeholder.',
            type: CandidateMediaType.socialPost,
          ),
        ),
        CandidateContentItem(
          id: 'pulse_victor_defense',
          candidateId: 'victor_chen',
          type: CandidateContentType.statement,
          headline: 'Chen answers with documents—and loses the room',
          summary: 'His detailed defense is accurate but difficult to follow.',
          inspectBody:
              'Chen cites the exact compliance scope and meeting dates. Reporters confirm the distinction, while residents criticize the answer as overly technical.',
          deepDivePrompt:
              'Compare communication style with the underlying record.',
          source: 'Bayhaven Evening Forum',
          fictionalDate: 'Campaign Day 12',
          cityIssueId: 'water_contamination',
          relatedEvidenceIds: ['victor_debateAnswer', 'victor_factCheck'],
          receiptKind: ReceiptKind.debateVersusFactCheck,
          candidateResponse:
              'My role is documented in the compliance review, not in the dam design.',
          publicAttention: 71,
        ),
        CandidateContentItem(
          id: 'pulse_victor_delay',
          candidateId: 'victor_chen',
          type: CandidateContentType.news,
          headline: 'Repair plans were accurate; two still arrived late',
          summary:
              'Records support Chen’s audits but raise questions about coalition power.',
          inspectBody:
              'Meeting minutes show council delays, not falsified reports. The same record leaves an unresolved political question: can Chen persuade enough council members as mayor?',
          deepDivePrompt:
              'Review the record and his debate answer on coalition support.',
          source: 'The Bayhaven Beacon',
          fictionalDate: 'Campaign Day 17',
          cityIssueId: 'water_contamination',
          relatedEvidenceIds: ['victor_publicRecord', 'victor_debateAnswer'],
          receiptKind: ReceiptKind.missingContext,
          missingContext:
              'The records explain the delays but cannot prove that Chen can build a governing coalition.',
          publicAttention: 66,
        ),
      ],
      relations: [
        EvidenceRelation(
          fromEvidenceId: 'victor_socialPost',
          toEvidenceId: 'victor_factCheck',
          type: EvidenceRelationType.corrects,
          explanation:
              'The fact-check establishes that Chen reviewed but did not design the dam.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'victor_platform',
          toEvidenceId: 'victor_budgetDocument',
          type: EvidenceRelationType.supports,
          explanation:
              'The budget confirms maintenance reserves and identifies tradeoffs.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'victor_campaignAd',
          toEvidenceId: 'victor_publicRecord',
          type: EvidenceRelationType.addsContext,
          explanation:
              'The public record confirms reporting quality and records delays.',
          unlocksTarget: true,
        ),
        EvidenceRelation(
          fromEvidenceId: 'victor_publicRecord',
          toEvidenceId: 'victor_debateAnswer',
          type: EvidenceRelationType.exposesMissingInformation,
          explanation:
              'The debate answer addresses how he would handle council resistance.',
        ),
      ],
      evidenceCosts: {
        'victor_profile': 0,
        'victor_platform': 0,
        'victor_campaignAd': 0,
        'victor_socialPost': 0,
        'victor_publicRecord': 1,
        'victor_budgetDocument': 1,
        'victor_factCheck': 1,
        'victor_controversy': 2,
        'victor_debateAnswer': 1,
      },
    ),
  },
  debateTopics: [
    DebateTopic(
      id: 'debate_water',
      title: 'Unsafe Water After the Floods',
      cityProblemId: 'water_contamination',
      issueFamilies: [CityIssueFamily.waterSupply],
      messages: [
        DebateMessage(
          id: 'dw01',
          topicId: 'debate_water',
          speakerId: 'moderator',
          type: DebateMessageType.moderator,
          text:
              'Families are boiling tap water tonight. What happens in your first thirty days?',
          sequence: 1,
          publicReaction: PublicReaction.skeptical,
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dw02',
          topicId: 'debate_water',
          speakerId: 'maya_vargas',
          type: DebateMessageType.claim,
          text:
              'Mobile testing teams go first. We cannot repair what we have not measured street by street.',
          sequence: 2,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['maya_platform'],
          relatedPromiseIds: ['promise_maya_water_testing'],
        ),
        DebateMessage(
          id: 'dw03',
          topicId: 'debate_water',
          speakerId: 'julian_pratt',
          type: DebateMessageType.claim,
          text:
              'Testing is not repair. I will bring private operators in immediately and replace the worst lines.',
          sequence: 3,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['julian_platform'],
        ),
        DebateMessage(
          id: 'dw04',
          topicId: 'debate_water',
          speakerId: 'victor_chen',
          type: DebateMessageType.claim,
          text:
              'Emergency bypasses first, then a published replacement sequence based on contamination and pressure loss.',
          sequence: 4,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['victor_platform', 'victor_budgetDocument'],
        ),
        DebateMessage(
          id: 'dw05',
          topicId: 'debate_water',
          speakerId: 'maya_vargas',
          type: DebateMessageType.rebuttal,
          text:
              'A private contract still needs inspectors. Fast paperwork does not make water safe.',
          sequence: 5,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['maya_debateAnswer'],
        ),
        DebateMessage(
          id: 'dw06',
          topicId: 'debate_water',
          speakerId: 'julian_pratt',
          type: DebateMessageType.rebuttal,
          text:
              'And another map does not put a crew in the ground. Bayhaven has waited long enough.',
          sequence: 6,
          publicReaction: PublicReaction.mixed,
          contradictedByIds: ['julian_budgetDocument'],
        ),
        DebateMessage(
          id: 'dw07',
          topicId: 'debate_water',
          speakerId: 'victor_chen',
          type: DebateMessageType.clarification,
          text:
              'The map already exists. The unresolved question is whether council will fund the full sequence.',
          sequence: 7,
          publicReaction: PublicReaction.surprised,
          referencedEvidenceIds: ['victor_publicRecord'],
          relatedHistoryEventIds: ['victor_delayed_upgrades_2021'],
          comparisonId: 'comparison_victor_coalition',
        ),
        DebateMessage(
          id: 'dw08',
          topicId: 'debate_water',
          speakerId: 'record_bot',
          type: DebateMessageType.recordCheck,
          text:
              'Record check: Chen’s reporting was accurate; Vargas has emergency-health experience; Pratt’s private-operator maintenance costs remain unclear.',
          sequence: 8,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: [
            'victor_publicRecord',
            'maya_publicRecord',
            'julian_budgetDocument',
          ],
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dw09',
          topicId: 'debate_water',
          speakerId: 'moderator',
          type: DebateMessageType.moderator,
          text: 'Name the tradeoff you are asking residents to accept.',
          sequence: 9,
          publicReaction: PublicReaction.skeptical,
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dw10',
          topicId: 'debate_water',
          speakerId: 'victor_chen',
          type: DebateMessageType.response,
          text:
              'Fewer immediate subsidies so repairs include maintenance funding instead of failing again.',
          sequence: 10,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['victor_budgetDocument'],
        ),
      ],
    ),
    DebateTopic(
      id: 'debate_jobs',
      title: 'Jobs That Last',
      cityProblemId: 'unemployment',
      issueFamilies: [CityIssueFamily.employmentQuality],
      messages: [
        DebateMessage(
          id: 'dj01',
          topicId: 'debate_jobs',
          speakerId: 'moderator',
          type: DebateMessageType.moderator,
          text:
              'Manufacturers are closing. How many jobs will still exist after city support ends?',
          sequence: 1,
          publicReaction: PublicReaction.skeptical,
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dj02',
          topicId: 'debate_jobs',
          speakerId: 'julian_pratt',
          type: DebateMessageType.claim,
          text:
              'My projects created thousands of jobs because I know how employers make decisions.',
          sequence: 2,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['julian_campaignAd'],
          contradictedByIds: ['julian_factCheck'],
          relatedPromiseIds: ['promise_julian_manufacturing'],
          comparisonId: 'comparison_julian_incentives',
        ),
        DebateMessage(
          id: 'dj03',
          topicId: 'debate_jobs',
          speakerId: 'maya_vargas',
          type: DebateMessageType.claim,
          text:
              'Paid health apprenticeships create work while filling real clinic shortages.',
          sequence: 3,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['maya_platform', 'maya_budgetDocument'],
        ),
        DebateMessage(
          id: 'dj04',
          topicId: 'debate_jobs',
          speakerId: 'victor_chen',
          type: DebateMessageType.claim,
          text:
              'Train local crews for the repair program and publish contract labor targets.',
          sequence: 4,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['victor_platform'],
        ),
        DebateMessage(
          id: 'dj05',
          topicId: 'debate_jobs',
          speakerId: 'maya_vargas',
          type: DebateMessageType.rebuttal,
          text:
              'The filings say many of Mr. Pratt’s celebrated jobs ended with the subsidy.',
          sequence: 5,
          publicReaction: PublicReaction.surprised,
          referencedEvidenceIds: ['julian_factCheck'],
        ),
        DebateMessage(
          id: 'dj06',
          topicId: 'debate_jobs',
          speakerId: 'julian_pratt',
          type: DebateMessageType.response,
          text:
              'Temporary work kept families afloat. I will not apologize for jobs that arrived when people needed them.',
          sequence: 6,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['julian_publicRecord'],
        ),
        DebateMessage(
          id: 'dj07',
          topicId: 'debate_jobs',
          speakerId: 'victor_chen',
          type: DebateMessageType.rebuttal,
          text:
              'Then publish temporary and permanent totals separately. Residents can understand an honest number.',
          sequence: 7,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['julian_socialPost', 'julian_factCheck'],
        ),
        DebateMessage(
          id: 'dj08',
          topicId: 'debate_jobs',
          speakerId: 'record_bot',
          type: DebateMessageType.recordCheck,
          text:
              'Fact-check: projects were completed, but the permanent-job claim lacks context.',
          sequence: 8,
          publicReaction: PublicReaction.skeptical,
          referencedEvidenceIds: ['julian_factCheck'],
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dj09',
          topicId: 'debate_jobs',
          speakerId: 'moderator',
          type: DebateMessageType.moderator,
          text:
              'Which plan creates work soon without leaving the next budget exposed?',
          sequence: 9,
          publicReaction: PublicReaction.mixed,
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dj10',
          topicId: 'debate_jobs',
          speakerId: 'maya_vargas',
          type: DebateMessageType.clarification,
          text:
              'My first-year gap is real. I would phase hiring if revenue arrives late rather than hide the risk.',
          sequence: 10,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['maya_budgetDocument'],
        ),
      ],
    ),
    DebateTopic(
      id: 'debate_clinics',
      title: 'Clinics, Budgets, and Accountability',
      cityProblemId: 'clinic_overload',
      issueFamilies: [CityIssueFamily.healthcareCapacity],
      messages: [
        DebateMessage(
          id: 'dc01',
          topicId: 'debate_clinics',
          speakerId: 'moderator',
          type: DebateMessageType.moderator,
          text:
              'Patients wait most of a day. What changes first, and who pays?',
          sequence: 1,
          publicReaction: PublicReaction.negative,
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dc02',
          topicId: 'debate_clinics',
          speakerId: 'maya_vargas',
          type: DebateMessageType.claim,
          text:
              'Extend hours, restore mobile units, and train paid apprentices. Care cannot wait for a perfect budget.',
          sequence: 2,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['maya_platform'],
          relatedPromiseIds: ['promise_maya_clinic_access'],
          comparisonId: 'comparison_maya_scale',
        ),
        DebateMessage(
          id: 'dc03',
          topicId: 'debate_clinics',
          speakerId: 'julian_pratt',
          type: DebateMessageType.response,
          text:
              'A stronger job base pays for services. The city keeps promising programs without growing revenue.',
          sequence: 3,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['julian_platform'],
        ),
        DebateMessage(
          id: 'dc04',
          topicId: 'debate_clinics',
          speakerId: 'victor_chen',
          type: DebateMessageType.response,
          text:
              'Publish staffing gaps and supply contracts first. Leakage in procurement also keeps shelves empty.',
          sequence: 4,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['victor_platform'],
        ),
        DebateMessage(
          id: 'dc05',
          topicId: 'debate_clinics',
          speakerId: 'julian_pratt',
          type: DebateMessageType.rebuttal,
          text:
              'Director Vargas had years in the health system. Why are the clinics still crowded?',
          sequence: 5,
          publicReaction: PublicReaction.surprised,
          referencedEvidenceIds: ['maya_profile'],
        ),
        DebateMessage(
          id: 'dc06',
          topicId: 'debate_clinics',
          speakerId: 'maya_vargas',
          type: DebateMessageType.response,
          text:
              'Because two pilots cannot replace a city budget. They did reduce waits where we could operate them.',
          sequence: 6,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['maya_publicRecord'],
          relatedHistoryEventIds: ['maya_mobile_clinics_2022'],
        ),
        DebateMessage(
          id: 'dc07',
          topicId: 'debate_clinics',
          speakerId: 'victor_chen',
          type: DebateMessageType.rebuttal,
          text:
              'The pilots worked, but the funding gap should be stated before the promise, not after it.',
          sequence: 7,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['maya_budgetDocument'],
        ),
        DebateMessage(
          id: 'dc08',
          topicId: 'debate_clinics',
          speakerId: 'record_bot',
          type: DebateMessageType.recordCheck,
          text:
              'Record check: the pilots improved waits in two districts and depended on a one-time grant.',
          sequence: 8,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['maya_publicRecord', 'maya_budgetDocument'],
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dc09',
          topicId: 'debate_clinics',
          speakerId: 'moderator',
          type: DebateMessageType.moderator,
          text:
              'Final accountability question: what should voters distrust in your own proposal?',
          sequence: 9,
          publicReaction: PublicReaction.surprised,
          bookmarkable: false,
        ),
        DebateMessage(
          id: 'dc10',
          topicId: 'debate_clinics',
          speakerId: 'julian_pratt',
          type: DebateMessageType.response,
          text:
              'Do not trust any job total—including mine—unless the city publishes how long each position lasts.',
          sequence: 10,
          publicReaction: PublicReaction.surprised,
          referencedEvidenceIds: ['julian_factCheck'],
        ),
        DebateMessage(
          id: 'dc11',
          topicId: 'debate_clinics',
          speakerId: 'maya_vargas',
          type: DebateMessageType.response,
          text:
              'Distrust my speed if the revenue does not arrive. That is why the rollout must be phased.',
          sequence: 11,
          publicReaction: PublicReaction.mixed,
          referencedEvidenceIds: ['maya_budgetDocument'],
        ),
        DebateMessage(
          id: 'dc12',
          topicId: 'debate_clinics',
          speakerId: 'victor_chen',
          type: DebateMessageType.response,
          text:
              'Distrust my timetable if I cannot secure council votes. A correct plan still needs a coalition.',
          sequence: 12,
          publicReaction: PublicReaction.positive,
          referencedEvidenceIds: ['victor_debateAnswer'],
          comparisonId: 'comparison_victor_coalition',
        ),
      ],
    ),
  ],
);
