import '../../domain/models/city_problem.dart';
import '../../domain/models/citybook.dart';

CityBookCatalog buildBayhavenCityBook() {
  const profiles = <String, CityBookProfile>{
    'maya_vargas': CityBookProfile(
      candidateId: 'maya_vargas',
      handle: '@MayaForBayhaven',
      shortBio:
          'Public-health administrator. Neighborhood care, open contracts, practical prevention.',
      affiliation: 'Kalinga Civic Alliance',
      publicAttention: 184200,
      profileAssetKey: 'citybook_maya_profile',
      bannerAssetKey: 'citybook_maya_banner',
    ),
    'julian_pratt': CityBookProfile(
      candidateId: 'julian_pratt',
      handle: '@PrattGetsItDone',
      shortBio:
          'Logistics executive. Jobs, speed, investment, and a city that moves.',
      affiliation: 'Forward Bayhaven Party',
      publicAttention: 231800,
      profileAssetKey: 'citybook_julian_profile',
      bannerAssetKey: 'citybook_julian_banner',
    ),
    'victor_chen': CityBookProfile(
      candidateId: 'victor_chen',
      handle: '@VictorChecksThePlan',
      shortBio:
          'Civil engineer and former water planner. Repair institutions before slogans.',
      affiliation: 'Independent Civic Reform',
      publicAttention: 126500,
      profileAssetKey: 'citybook_victor_profile',
      bannerAssetKey: 'citybook_victor_banner',
    ),
  };

  const posts = <CityBookPost>[
    CityBookPost(
      id: 'cb_maya_clinics',
      candidateId: 'maya_vargas',
      fictionalDate: 'September 14, 2025',
      type: CityBookPostType.policyStatement,
      text:
          'Longer clinic hours and mobile care should reach the neighborhoods that wait the longest. Our first-year plan starts with the highest-pressure districts.',
      imageAssetKey: 'citybook_maya_clinic_plan',
      imageAspectRatio: 4 / 3,
      relatedIssueFamilies: [CityIssueFamily.healthcareCapacity],
      relatedEvidenceIds: ['maya_platform', 'maya_budgetDocument'],
      relatedDebateMessageIds: ['dc02'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 8200,
        CityBookReaction.love: 3100,
        CityBookReaction.receipt: 4600,
        CityBookReaction.angry: 900,
      }),
      commentThreadId: 'thread_cb_maya_clinics',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.publicClaim,
    ),
    CityBookPost(
      id: 'cb_maya_contracts',
      candidateId: 'maya_vargas',
      fictionalDate: 'September 21, 2025',
      type: CityBookPostType.criticismResponse,
      text:
          'Questions about campaign donors deserve answers. Every clinic contract under my administration will go through published competitive bidding.',
      relatedIssueFamilies: [CityIssueFamily.corruptionPublicFunds],
      relatedEvidenceIds: ['maya_controversy', 'maya_platform'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 5100,
        CityBookReaction.love: 1200,
        CityBookReaction.receipt: 12800,
        CityBookReaction.angry: 1400,
        CityBookReaction.laugh: 900,
      }),
      commentThreadId: 'thread_cb_maya_contracts',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.disputedClaim,
    ),
    CityBookPost(
      id: 'cb_maya_water',
      candidateId: 'maya_vargas',
      fictionalDate: 'October 2, 2025',
      type: CityBookPostType.publicServiceAnnouncement,
      text:
          'If your street has low pressure or cloudy water after heavy rain, report it. Mobile testing must come before confident speeches.',
      relatedIssueFamilies: [CityIssueFamily.waterSupply],
      relatedEvidenceIds: ['maya_debateAnswer'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 6900,
        CityBookReaction.love: 1800,
        CityBookReaction.receipt: 2200,
        CityBookReaction.sad: 700,
      }),
      commentThreadId: 'thread_cb_maya_water',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.candidateOpinion,
    ),
    CityBookPost(
      id: 'cb_maya_old_scale',
      candidateId: 'maya_vargas',
      fictionalDate: 'June 8, 2022',
      type: CityBookPostType.historical,
      text:
          'Small pilots are useful because citywide expansion before stable funding can leave patients with another unfinished promise.',
      relatedIssueFamilies: [CityIssueFamily.healthcareCapacity],
      relatedEvidenceIds: ['maya_publicRecord', 'maya_budgetDocument'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 1600,
        CityBookReaction.receipt: 7400,
        CityBookReaction.shock: 2100,
      }),
      commentThreadId: 'thread_cb_maya_old_scale',
      historical: true,
      visibility: CityBookVisibility.resurfaced,
      sourceTruthRelation: CityBookSourceTruthRelation.documentedClaim,
      comparisonId: 'comparison_maya_scale',
    ),
    CityBookPost(
      id: 'cb_julian_jobs',
      candidateId: 'julian_pratt',
      fictionalDate: 'September 13, 2025',
      type: CityBookPostType.campaignAnnouncement,
      text:
          'Bayhaven can sign employers, clear sites, and put people to work now. Delay is a policy choice, and I choose delivery.',
      imageAssetKey: 'citybook_julian_jobs_rally',
      imageAspectRatio: 1,
      relatedIssueFamilies: [CityIssueFamily.employmentQuality],
      relatedEvidenceIds: ['julian_platform', 'julian_campaignAd'],
      relatedDebateMessageIds: ['dj02'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 12400,
        CityBookReaction.love: 5200,
        CityBookReaction.receipt: 3700,
        CityBookReaction.angry: 1800,
      }),
      commentThreadId: 'thread_cb_julian_jobs',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.publicClaim,
    ),
    CityBookPost(
      id: 'cb_julian_projects',
      candidateId: 'julian_pratt',
      fictionalDate: 'September 27, 2025',
      type: CityBookPostType.accomplishmentClaim,
      text:
          'Our development board opened projects while critics held meetings. Bayhaven needs that same urgency at City Hall.',
      relatedIssueFamilies: [CityIssueFamily.unfinishedRoads],
      relatedEvidenceIds: ['julian_publicRecord', 'julian_factCheck'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 9800,
        CityBookReaction.love: 2600,
        CityBookReaction.receipt: 9100,
        CityBookReaction.laugh: 1700,
      }),
      commentThreadId: 'thread_cb_julian_projects',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.disputedClaim,
    ),
    CityBookPost(
      id: 'cb_julian_water',
      candidateId: 'julian_pratt',
      fictionalDate: 'October 1, 2025',
      type: CityBookPostType.policyStatement,
      text:
          'Emergency operators can stabilize water service while the city replaces failing lines. Public ownership without working taps is not a solution.',
      relatedIssueFamilies: [CityIssueFamily.waterSupply],
      relatedEvidenceIds: ['julian_debateAnswer', 'julian_budgetDocument'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 7700,
        CityBookReaction.angry: 5200,
        CityBookReaction.receipt: 6800,
        CityBookReaction.shock: 1200,
      }),
      commentThreadId: 'thread_cb_julian_water',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.publicClaim,
    ),
    CityBookPost(
      id: 'cb_julian_old_incentives',
      candidateId: 'julian_pratt',
      fictionalDate: 'March 3, 2021',
      type: CityBookPostType.historical,
      text:
          'Businesses create jobs when government gets out of the way. Complicated conditions only scare investment into the next city.',
      relatedIssueFamilies: [CityIssueFamily.employmentQuality],
      relatedEvidenceIds: ['julian_publicRecord', 'julian_platform'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 3500,
        CityBookReaction.receipt: 8100,
        CityBookReaction.angry: 2400,
      }),
      commentThreadId: 'thread_cb_julian_old_incentives',
      historical: true,
      visibility: CityBookVisibility.resurfaced,
      sourceTruthRelation: CityBookSourceTruthRelation.documentedClaim,
      comparisonId: 'comparison_julian_incentives',
    ),
    CityBookPost(
      id: 'cb_victor_water',
      candidateId: 'victor_chen',
      fictionalDate: 'September 15, 2025',
      type: CityBookPostType.policyStatement,
      text:
          'Publish the failure map, repair the highest-risk lines first, and show residents the schedule. Engineering cannot be replaced by a slogan.',
      imageAssetKey: 'citybook_victor_water_plan',
      imageAspectRatio: 4 / 3,
      relatedIssueFamilies: [CityIssueFamily.waterSupply],
      relatedEvidenceIds: ['victor_platform', 'victor_publicRecord'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 6100,
        CityBookReaction.love: 900,
        CityBookReaction.receipt: 3300,
        CityBookReaction.laugh: 400,
      }),
      commentThreadId: 'thread_cb_victor_water',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.documentedClaim,
    ),
    CityBookPost(
      id: 'cb_victor_dam',
      candidateId: 'victor_chen',
      fictionalDate: 'September 25, 2025',
      type: CityBookPostType.clarification,
      text:
          'I reviewed technical compliance on the dam contract; I did not select the contractor. The review and my recommendation should both be public.',
      relatedIssueFamilies: [CityIssueFamily.corruptionPublicFunds],
      relatedEvidenceIds: ['victor_controversy', 'victor_publicRecord'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 3800,
        CityBookReaction.receipt: 11200,
        CityBookReaction.angry: 2300,
        CityBookReaction.shock: 1200,
      }),
      commentThreadId: 'thread_cb_victor_dam',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.disputedClaim,
    ),
    CityBookPost(
      id: 'cb_victor_audit',
      candidateId: 'victor_chen',
      fictionalDate: 'October 4, 2025',
      type: CityBookPostType.campaignAnnouncement,
      text:
          'Every major project should have a public milestone, contract trail, change-order history, and named accountable office.',
      relatedIssueFamilies: [
        CityIssueFamily.corruptionPublicFunds,
        CityIssueFamily.unfinishedRoads,
      ],
      relatedEvidenceIds: ['victor_platform', 'victor_budgetDocument'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 5800,
        CityBookReaction.love: 1100,
        CityBookReaction.receipt: 2700,
      }),
      commentThreadId: 'thread_cb_victor_audit',
      visibility: CityBookVisibility.public,
      sourceTruthRelation: CityBookSourceTruthRelation.publicClaim,
    ),
    CityBookPost(
      id: 'cb_victor_old_coalition',
      candidateId: 'victor_chen',
      fictionalDate: 'August 17, 2020',
      type: CityBookPostType.historical,
      text:
          'Technical offices should remain insulated from political bargaining. Good projects should stand on the quality of the plan.',
      relatedIssueFamilies: [CityIssueFamily.governmentServices],
      relatedEvidenceIds: ['victor_profile', 'victor_debateAnswer'],
      reactions: CityBookReactionDistribution({
        CityBookReaction.like: 1400,
        CityBookReaction.receipt: 6500,
        CityBookReaction.laugh: 1200,
      }),
      commentThreadId: 'thread_cb_victor_old_coalition',
      historical: true,
      visibility: CityBookVisibility.resurfaced,
      sourceTruthRelation: CityBookSourceTruthRelation.documentedClaim,
      comparisonId: 'comparison_victor_coalition',
    ),
  ];

  final threads = <String, CityBookCommentThread>{
    for (final post in posts) post.commentThreadId: _threadFor(post),
  };
  return CityBookCatalog(
    profiles: profiles,
    posts: posts,
    commentThreads: threads,
  );
}

CityBookCommentThread _baseThreadFor(CityBookPost post) {
  final comments = switch (post.candidateId) {
    'maya_vargas' => const [
      (
        'Nica Ramos',
        '@nicaSouthPoint',
        CityBookCommentArchetype.affectedResident,
        'Open nga minsan, wala namang gamot.',
      ),
      (
        'Joel M.',
        '@joelcommutes',
        CityBookCommentArchetype.skepticalCitizen,
        'The South Point pilot helped. Show us where the permanent funding comes from.',
      ),
      (
        'CareTeam Bayhaven',
        '@careteamvolunteers',
        CityBookCommentArchetype.campaignVolunteer,
        'The full proposal and schedule are linked in the campaign page.',
      ),
      (
        'ReceiptHunter88',
        '@receipthunter88',
        CityBookCommentArchetype.habitualCritic,
        'ASK HER ABOUT THE CONTRACT.',
      ),
      (
        'Mila S.',
        '@milasays',
        CityBookCommentArchetype.confusedCommenter,
        'Bakit puro away dito 😭 Can someone explain the budget part?',
      ),
    ],
    'julian_pratt' => const [
      (
        'Paolo Cruz',
        '@paoloworks',
        CityBookCommentArchetype.supporter,
        'People need jobs now, not another two-year study.',
      ),
      (
        'Ari Velasco',
        '@ari_reads',
        CityBookCommentArchetype.policyFocusedCitizen,
        'How many positions are permanent and what happens when incentives expire?',
      ),
      (
        'MOVE BAYHAVEN NOW',
        '@movebayhavennow24',
        CityBookCommentArchetype.suspiciousAccount,
        'JULIAN DELIVERS. JULIAN DELIVERS. #MoveNow',
      ),
      (
        'Tess Mercado',
        '@tessmarket',
        CityBookCommentArchetype.affectedResident,
        'Temporary work still paid our rent, but temporary is temporary.',
      ),
      (
        'Danilo P.',
        '@danilop',
        CityBookCommentArchetype.sarcasticCommenter,
        'Fast paperwork, faster ribbon cutting.',
      ),
    ],
    _ => const [
      (
        'Lina Chua',
        '@linachua',
        CityBookCommentArchetype.supporter,
        'At least someone is showing an actual process.',
      ),
      (
        'Benjie Flores',
        '@benjieF',
        CityBookCommentArchetype.skepticalCitizen,
        'A good plan still needs council votes and a budget.',
      ),
      (
        'Riverside Watch',
        '@riversidewatch',
        CityBookCommentArchetype.affectedResident,
        'Please publish the repair order street by street.',
      ),
      (
        'FixItFirst',
        '@fixitfirst2025',
        CityBookCommentArchetype.suspiciousAccount,
        'ONLY ENGINEERS CAN SAVE BAYHAVEN #NoMoreTalk',
      ),
      (
        'Mae T.',
        '@maet',
        CityBookCommentArchetype.jokeCommenter,
        'I support any spreadsheet that makes my tap water normal.',
      ),
    ],
  };
  return CityBookCommentThread(
    id: post.commentThreadId,
    comments: [
      for (var index = 0; index < comments.length; index++)
        CityBookComment(
          id: '${post.commentThreadId}_$index',
          authorName: comments[index].$1,
          authorHandle: comments[index].$2,
          archetype: comments[index].$3,
          text: comments[index].$4,
          reactionCount: 14 + index * 17,
          accountClues:
              comments[index].$3 == CityBookCommentArchetype.suspiciousAccount
              ? const [
                  'Recently created',
                  'Repeated slogan pattern',
                  'High posting frequency',
                ]
              : const [],
        ),
    ],
  );
}

CityBookCommentThread _threadFor(CityBookPost post) {
  final base = _baseThreadFor(post);
  final context = _commentContextFor(post.id);
  final candidateName = switch (post.candidateId) {
    'maya_vargas' => 'Maya',
    'julian_pratt' => 'Julian',
    _ => 'Victor',
  };
  final campaignReply = switch (post.candidateId) {
    'maya_vargas' =>
      'The Maya campaign says the linked records explain the ${context.topic} proposal. Read them and keep asking questions.',
    'julian_pratt' =>
      'Team Pratt posted the supporting material for ${context.topic}. Delivery details are in the linked documents.',
    _ =>
      'Victor\'s team says the records behind ${context.topic} are linked. Check the documents, not only this comment.',
  };
  final suspiciousPitch = switch (post.candidateId) {
    'maya_vargas' =>
      'MAYA CARES. MAYA CARES. ${context.topic.toUpperCase()} NOW. #KalingaWorks',
    'julian_pratt' =>
      'JULIAN DELIVERS. JULIAN DELIVERS. ${context.topic.toUpperCase()} NOW. #MoveNow',
    _ => 'ONLY VICTOR HAS A PLAN. ${context.topic.toUpperCase()}. #NoMoreTalk',
  };
  final confused = post.historical
      ? 'Old post ito, right? Is this still $candidateName\'s position on ${context.topic}, or did the plan change?'
      : 'Can someone explain when the ${context.topic} plan starts and who actually pays for it?';
  final comments = <({CityBookCommentArchetype archetype, String text})>[
    (archetype: CityBookCommentArchetype.supporter, text: context.supportive),
    (
      archetype: CityBookCommentArchetype.affectedResident,
      text: context.affected,
    ),
    (
      archetype: CityBookCommentArchetype.skepticalCitizen,
      text: context.skeptical,
    ),
    (
      archetype: CityBookCommentArchetype.policyFocusedCitizen,
      text: context.policyQuestion,
    ),
    (archetype: CityBookCommentArchetype.angryResident, text: context.critical),
    (
      archetype: CityBookCommentArchetype.oppositionSupporter,
      text:
          'This sounds good in a post, but ${context.topic} needs proof and implementation, not another campaign line.',
    ),
    (
      archetype: CityBookCommentArchetype.campaignVolunteer,
      text: campaignReply,
    ),
    (
      archetype: CityBookCommentArchetype.sarcasticCommenter,
      text: context.sarcastic,
    ),
    (archetype: CityBookCommentArchetype.confusedCommenter, text: confused),
    (
      archetype: CityBookCommentArchetype.suspiciousAccount,
      text: suspiciousPitch,
    ),
  ];
  final authorOffset = _stableHash(post.id) % base.comments.length;
  return CityBookCommentThread(
    id: post.commentThreadId,
    comments: [
      for (var index = 0; index < comments.length; index++)
        CityBookComment(
          id: '${post.commentThreadId}_$index',
          authorName:
              comments[index].archetype ==
                  CityBookCommentArchetype.suspiciousAccount
              ? '$candidateName Updates 2025'
              : _regularCommentAuthor(base, authorOffset, index).name,
          authorHandle:
              comments[index].archetype ==
                  CityBookCommentArchetype.suspiciousAccount
              ? '@${candidateName.toLowerCase()}updates25'
              : _regularCommentAuthor(base, authorOffset, index).handle,
          archetype: comments[index].archetype,
          text: comments[index].text,
          reactionCount: 9 + (_stableHash('${post.id}_$index') % 180),
          accountClues:
              comments[index].archetype ==
                  CityBookCommentArchetype.suspiciousAccount
              ? const [
                  'Recently created',
                  'Repeated slogan pattern',
                  'High posting frequency',
                ]
              : const [],
        ),
    ],
  );
}

({String name, String handle}) _regularCommentAuthor(
  CityBookCommentThread base,
  int offset,
  int index,
) {
  if (index < base.comments.length) {
    final author = base.comments[(offset + index) % base.comments.length];
    return (name: author.authorName, handle: author.authorHandle);
  }
  const additional = <({String name, String handle})>[
    (name: 'Rina Solis', handle: '@rinasolis'),
    (name: 'Omar Dela Cruz', handle: '@omarDC'),
    (name: 'Kaye Lim', handle: '@kayelimreads'),
    (name: 'Tomas Bayani', handle: '@tomasbayani'),
  ];
  return additional[index - base.comments.length];
}

class _PostCommentContext {
  const _PostCommentContext({
    required this.topic,
    required this.supportive,
    required this.affected,
    required this.skeptical,
    required this.policyQuestion,
    required this.critical,
    required this.sarcastic,
  });

  final String topic;
  final String supportive;
  final String affected;
  final String skeptical;
  final String policyQuestion;
  final String critical;
  final String sarcastic;
}

_PostCommentContext _commentContextFor(String postId) => switch (postId) {
  'cb_maya_clinics' => const _PostCommentContext(
    topic: 'longer clinic hours and mobile care',
    supportive:
        'Longer clinic hours would help workers who cannot line up before sunrise.',
    affected:
        'My mother uses the South Point clinic. Open hours help, but medicines and staff must be there too.',
    skeptical:
        'Is the first-year clinic expansion funded every year, or only by a temporary grant?',
    policyQuestion:
        'Publish the target districts, staffing ratios, medicine budget, and monthly opening schedule.',
    critical:
        'We already waited through one pilot with shortages. Do not announce more clinics without nurses and supplies.',
    sarcastic:
        'A clinic open at night would be amazing. A doctor inside it would be an excellent bonus.',
  ),
  'cb_maya_contracts' => const _PostCommentContext(
    topic: 'competitive bidding for clinic contracts',
    supportive:
        'Publishing every clinic bid and contract owner should be the minimum standard.',
    affected:
        'Small local suppliers need fair bidding too. The same connected firms always seem to hear first.',
    skeptical:
        'Will donor-linked companies be barred, disclosed, or simply allowed to bid like everyone else?',
    policyQuestion:
        'Publish beneficial owners, losing bids, scoring sheets, change orders, and conflict disclosures.',
    critical:
        'The donor questions came first and the transparency promise came after. That timing matters.',
    sarcastic:
        'Transparency is apparently arriving right after the campaign finance report.',
  ),
  'cb_maya_water' => const _PostCommentContext(
    topic: 'mobile water testing after heavy rain',
    supportive:
        'Testing before officials declare the water safe is common sense. Please deploy this in Riverside.',
    affected:
        'Our tap turns cloudy after hard rain. We need sample results, not another hotline number.',
    skeptical:
        'How quickly can a mobile team arrive, and which laboratory confirms the result?',
    policyQuestion:
        'Post the testing route, response-time target, contaminants checked, and public result dashboard.',
    critical:
        'Residents have reported this for months. Telling us to report it again is not the same as fixing the pipes.',
    sarcastic:
        'Step one: photograph cloudy water. Step two: wait on hold while boiling it anyway.',
  ),
  'cb_maya_old_scale' => const _PostCommentContext(
    topic: 'citywide clinic expansion and stable funding',
    supportive:
        'This older warning was reasonable. Scaling a weak pilot can spread the same failure everywhere.',
    affected:
        'The pilot helped my barangay, but the pharmacy was empty twice. Funding stability is a real concern.',
    skeptical:
        'If citywide expansion was risky in 2022, what changed enough to make it workable now?',
    policyQuestion:
        'Show the old pilot results beside the new staffing, funding, and district assumptions.',
    critical:
        'The caution in this post disappeared once expansion became a campaign promise.',
    sarcastic:
        'Apparently a pilot becomes scalable when election season adds enough confidence.',
  ),
  'cb_julian_jobs' => const _PostCommentContext(
    topic: 'fast employer deals and new jobs',
    supportive:
        'People need paychecks now. If employers are ready, the city should stop losing them to nearby ports.',
    affected:
        'Temporary warehouse work paid our rent, but I need to know whether these promised jobs are permanent.',
    skeptical:
        'How many jobs are direct hires, how many are contractors, and what happens after incentives expire?',
    policyQuestion:
        'Publish wage floors, contract length, local-hiring targets, subsidy cost, and job-retention reports.',
    critical:
        'A ribbon cutting is not job security. We have seen three-month contracts called employment wins.',
    sarcastic:
        'Nothing says stable career like a campaign graphic with no salary range.',
  ),
  'cb_julian_projects' => const _PostCommentContext(
    topic: 'the development board project record',
    supportive:
        'At least the board finished projects instead of studying them forever. Speed matters.',
    affected:
        'The access road opened, but our shop lost customers during the delays. Both parts belong in the story.',
    skeptical:
        'How many projects opened on time, and how many were counted before every phase was complete?',
    policyQuestion:
        'List each project, original deadline, actual completion date, cost change, and measured public benefit.',
    critical:
        'Critics were not just holding meetings. Some were asking why the project was late and over budget.',
    sarcastic:
        'If the ribbon is cut fast enough, perhaps nobody notices the unfinished drainage beside it.',
  ),
  'cb_julian_water' => const _PostCommentContext(
    topic: 'emergency private operators for water service',
    supportive:
        'I care less about the operator label than whether clean water reaches the tap this week.',
    affected:
        'Our block has water four hours a day. An emergency fix helps, but do not lock us into a bad long contract.',
    skeptical:
        'Who sets the operator fee, performance rules, exit date, and penalty for failure?',
    policyQuestion:
        'Publish the contract length, tariff protection, repair targets, procurement route, and ownership safeguards.',
    critical:
        'Calling privatization an emergency measure does not remove the profit motive or the public risk.',
    sarcastic: 'Working taps first, surprise thirty-year contract later?',
  ),
  'cb_julian_old_incentives' => const _PostCommentContext(
    topic: 'business incentives without conditions',
    supportive:
        'The old post is direct: too many conditions can push investment somewhere else.',
    affected:
        'A factory hired for one year, then cut staff after the tax break. Conditions can protect workers.',
    skeptical:
        'Does Julian still oppose hiring and wage conditions, or has the current jobs plan changed?',
    policyQuestion:
        'Compare the 2021 position with today\'s wage, retention, clawback, and local-hiring rules.',
    critical:
        'Government getting out of the way often means workers carry the risk while firms keep the incentive.',
    sarcastic:
        'Please do not frighten the investors by asking whether the jobs last.',
  ),
  'cb_victor_water' => const _PostCommentContext(
    topic: 'risk-based water-line repairs',
    supportive:
        'A public failure map would finally show why one street gets fixed before another.',
    affected:
        'Riverside has had weak pressure for months. Put our line on the map and give us an honest date.',
    skeptical:
        'Who verifies the risk ranking, and can politically connected districts jump the queue?',
    policyQuestion:
        'Publish failure criteria, street schedule, contractor milestones, delays, and pressure tests.',
    critical:
        'We have seen many engineering plans. Residents need crews, materials, and a funded schedule.',
    sarcastic:
        'My faucet is excited to receive its spreadsheet and tentative milestone.',
  ),
  'cb_victor_dam' => const _PostCommentContext(
    topic: 'Victor’s role in the dam contract review',
    supportive:
        'Publishing the review and recommendation is right. Let people read what he actually signed.',
    affected:
        'Communities near the project deserve the safety review, not a debate over job titles.',
    skeptical:
        'Did the technical review flag risks, and did Victor follow up after contract approval?',
    policyQuestion:
        'Release the compliance checklist, recommendation, meeting dates, signatories, and change orders.',
    critical:
        'He may not have selected the contractor, but technical approval still carries responsibility.',
    sarcastic:
        'Not my contractor, only my technical signature is not the cleanest campaign slogan.',
  ),
  'cb_victor_audit' => const _PostCommentContext(
    topic: 'public milestones and contract trails',
    supportive:
        'Named offices and visible change orders would make unfinished work harder to hide.',
    affected:
        'Our road was marked complete while drainage remained open. Milestones need inspections.',
    skeptical:
        'Who updates the portal when an agency misses a milestone, and what consequence follows?',
    policyQuestion:
        'Include original deadlines, revisions, payments, inspections, change orders, and responsible officers.',
    critical:
        'A dashboard cannot replace enforcement. We already have records that nobody acts on.',
    sarcastic:
        'Great, now the delayed project can have a beautifully documented delay.',
  ),
  _ => const _PostCommentContext(
    topic: 'technical offices and political coalitions',
    supportive:
        'Technical decisions should not be traded for favors. The older position still has value.',
    affected:
        'Our flood project had a sound plan but stalled without council support. Independence did not build it.',
    skeptical:
        'Does Victor still believe plans can stand without negotiation, or has his position evolved?',
    policyQuestion:
        'Compare this 2020 statement with his current coalition strategy and safeguards.',
    critical:
        'Treating every negotiation as contamination can leave good projects unfunded.',
    sarcastic:
        'Excellent plan. Unfortunately, the council has left the group chat.',
  ),
};

int _stableHash(String value) => value.codeUnits.fold(
  0,
  (hash, codeUnit) => ((hash * 31) + codeUnit) & 0x7fffffff,
);
