// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Resibo, Please';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageDescription =>
      'Choose the language used throughout the game.';

  @override
  String get languageSystem => 'Device language';

  @override
  String get languageSystemDescription =>
      'Use your phone or browser language when supported.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishDescription => 'Play using English text.';

  @override
  String get languageFilipino => 'Filipino';

  @override
  String get languageFilipinoDescription =>
      'Maglaro gamit ang tekstong Filipino.';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get reduceMotionDescription =>
      'Use simpler transitions and stop decorative movement. Device reduced-motion settings are always respected.';

  @override
  String get highContrast => 'High contrast';

  @override
  String get highContrastDescription =>
      'Strengthen text, border, and surface contrast for easier reading.';

  @override
  String get audio => 'Audio';

  @override
  String get audioDescription =>
      'Control interface sounds, dialogue blips, and future background music.';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsDescription =>
      'Play subtle sounds for buttons, evidence, voting, and city developments.';

  @override
  String get music => 'Background music';

  @override
  String get musicDescription =>
      'Play the soundtrack when licensed music files are installed.';

  @override
  String get sfxVolume => 'Sound-effect volume';

  @override
  String get musicVolume => 'Music volume';

  @override
  String get deviceTextSize => 'Text size follows your device';

  @override
  String get deviceTextSizeDescription =>
      'Resibo, Please respects the font size selected in your device accessibility settings.';

  @override
  String get information => 'Information';

  @override
  String get aboutTitle => 'About Resibo, Please';

  @override
  String get aboutBody =>
      'Resibo, Please is a fictional civic decision simulation about evidence, policy tradeoffs, and the consequences of voting choices. It does not endorse real candidates or parties.';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsBody =>
      'Created as an independent educational game prototype. Design, writing, programming, and original fictional content by the Resibo, Please project team.';

  @override
  String get disclaimerTitle => 'Disclaimer';

  @override
  String get disclaimerBody =>
      'Every city, candidate, party, media outlet, and event is fictional. This game is not official election guidance and must not replace verified information about real elections.';

  @override
  String get privacyTitle => 'Privacy notice';

  @override
  String get privacyBody =>
      'This prototype stores settings and fictional city runs on your device so they survive app restarts. It does not require an account or transmit personal information or city saves to a game server. Clearing site or app storage may remove local saves. This notice must be reviewed before any online features are released.';

  @override
  String get appVersion => 'App version';

  @override
  String get appVersionValue => '1.0.0 (1)';

  @override
  String get resetSettings => 'Reset settings';

  @override
  String get resetSettingsDescription =>
      'Restore device language, standard contrast, and normal in-game motion. City files are not deleted.';

  @override
  String get resetSettingsQuestion => 'Reset all settings?';

  @override
  String get resetSettingsConfirmation =>
      'Language, accessibility, and audio preferences will return to their defaults. City files will stay untouched.';

  @override
  String get settingsResetNotice => 'Settings restored to defaults.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get understood => 'Understood';

  @override
  String get gotIt => 'Got it';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get standard => 'Standard';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get mainMenu => 'Main menu';

  @override
  String get backToMainMenu => 'Back to Main Menu';

  @override
  String get startNewCity => 'Start New City';

  @override
  String get continueCity => 'Continue City';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get visitCities => 'Visit Cities';

  @override
  String get fictionalDisclaimer =>
      'A fictional civic decision simulation.\nNot official election guidance.';

  @override
  String get visitCitiesBody =>
      'Browse sanitized fictional city results retrieved from the Public City Gallery API.';

  @override
  String get menuBackgroundSemantics =>
      'A civic hall, neighborhoods, clinic, school, drainage canal, and waterfront.';

  @override
  String get candidateGroupSemantics =>
      'Mayoral candidates Julian Pratt, Maya Vargas, and Victor Chen.';

  @override
  String get logoSemantics => 'Resibo, Please';

  @override
  String get splash1 => 'Find the receipts.';

  @override
  String get splash2 => 'Style or platform?';

  @override
  String get splash3 => 'Facts before fanfare.';

  @override
  String get splash4 => 'Check the source first.';

  @override
  String get splash5 => 'The city remembers.';

  @override
  String get splash6 => 'Popularity is not proof.';

  @override
  String get splash7 => 'Read the fine print.';

  @override
  String get splash8 => 'No receipt, less trust.';

  @override
  String get splash9 => 'Promises are easy to say.';

  @override
  String get splash10 => 'Vote now, consequences later.';

  @override
  String get splash11 => 'Not all noise is policy.';

  @override
  String get splash12 => 'A plan—or only a slogan?';

  @override
  String get voterPocketGuide => 'The voter\'s pocket guide';

  @override
  String get youAreTheVoter => 'You are the voter';

  @override
  String get youAreTheVoterBody =>
      'Help a fictional city, one election at a time. Look for good evidence, make a choice, and live with the result.';

  @override
  String get guideReadCity => 'Read the city';

  @override
  String get guideReadCityBody =>
      'See what is going wrong and which problems need attention first.';

  @override
  String get guideCheckCandidates => 'Check the candidates';

  @override
  String get guideCheckCandidatesBody =>
      'Open their files. Compare promises, records, and sources. Noise is not proof.';

  @override
  String get guideChoose => 'Choose for yourself';

  @override
  String get guideChooseBody =>
      'Cast your vote. The game will not tell you who is best.';

  @override
  String get guideWatchTerm => 'Watch the term';

  @override
  String get guideWatchTermBody =>
      'Your choice governs. Plans, skill, honesty, money, and surprise events shape the city.';

  @override
  String get guideFindReceipts => 'Find the receipts';

  @override
  String get guideFindReceiptsBody =>
      'See what improved, what got worse, and why. Then carry that city into the next election.';

  @override
  String get remember => 'Remember';

  @override
  String get guideRememberBody =>
      'There is no perfect candidate and no hidden match score. Compare the evidence, decide what matters, and own the tradeoffs.';

  @override
  String get cityHallRecords => 'City hall records';

  @override
  String get cityArchive => 'City archive';

  @override
  String get newCityPermit => 'New city permit';

  @override
  String get recordsWarning => 'Records division warning';

  @override
  String get configureNewCity => 'Configure New City';

  @override
  String get deleteCityQuestion => 'Delete City?';

  @override
  String get backToSaveSlots => 'Back to save slots';

  @override
  String get backToMainMenuTooltip => 'Back to main menu';

  @override
  String get startCityIntro =>
      'Choose an empty file. Your new city will be kept in that save slot.';

  @override
  String get continueCityIntro =>
      'Choose a city file to continue, or use the red button to delete it.';

  @override
  String get emptyCityFile => 'Empty city file';

  @override
  String get tapToRegisterCity => 'Tap to register a new city.';

  @override
  String get noSavedCityHere => 'No saved city here yet.';

  @override
  String get occupied => 'Occupied';

  @override
  String get current => 'Current';

  @override
  String get slot => 'Slot';

  @override
  String saveSlotNumber(int number) {
    return 'Save slot $number';
  }

  @override
  String get allSlotsOccupied =>
      'All five files are occupied. Open Continue City and delete a file before starting another.';

  @override
  String get startANewCity => 'Start a New City';

  @override
  String get electionBriefProgress => 'Election brief';

  @override
  String get termInProgressProgress => 'Term in progress';

  @override
  String get termReportReadyProgress => 'Term report ready';

  @override
  String caseTermLabel(String scenario, int term) {
    return '$scenario case • Term $term';
  }

  @override
  String shredCityQuestion(String city) {
    return 'Shred “$city”?';
  }

  @override
  String deleteCityBody(int slot) {
    return 'This removes the city from Save Slot $slot. Its election history and progress cannot be recovered.';
  }

  @override
  String get cannotBeUndone => 'This cannot be undone';

  @override
  String get keepCityFile => 'Keep City File';

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String cityRemovedNotice(String city, int slot) {
    return '$city was removed from Save Slot $slot.';
  }

  @override
  String get cityRegistrationForm => 'City registration form';

  @override
  String get cityRegistrationIntro =>
      'Complete all seven entries. Every choice changes the city file or how you investigate it.';

  @override
  String get cityName => 'City name';

  @override
  String get cityNameDescription =>
      'Name the city file that voters will carry through a term.';

  @override
  String get cityNameHint => 'e.g. Mabuhay City';

  @override
  String get cityNameError => 'Enter at least 2 characters.';

  @override
  String get startingPressure => 'Starting pressure';

  @override
  String get startingPressureDescription =>
      'Choose how much strain the city faces on day one.';

  @override
  String get mainConcerns => 'Main concerns';

  @override
  String get mainConcernsDescription =>
      'Choose one to three urgent issues for this election.';

  @override
  String selectedConcernCount(int count) {
    return '$count of 3 selected';
  }

  @override
  String get keepOneConcern => 'Keep at least one main concern.';

  @override
  String get removeConcernFirst =>
      'Remove one concern before choosing another.';

  @override
  String get candidateField => 'Candidate field';

  @override
  String get candidateFieldDescription =>
      'Set the general governing experience of the ballot.';

  @override
  String get assistanceMode => 'Assistance mode';

  @override
  String get assistanceModeDescription =>
      'Choose whether Resi offers neutral learning reminders.';

  @override
  String get campaignNoise => 'Campaign noise';

  @override
  String get campaignNoiseDescription =>
      'Control how much weak or distracting material appears.';

  @override
  String get investigationTime => 'Investigation time';

  @override
  String get investigationTimeDescription =>
      'Choose how many evidence files may be opened this run.';

  @override
  String get cityFileSummary => 'City file summary';

  @override
  String configurationSummaryLine(
    String pressure,
    String candidates,
    String noise,
  ) {
    return '$pressure pressure • $candidates candidates • $noise campaign';
  }

  @override
  String configurationConcerns(String concerns) {
    return 'Concerns: $concerns';
  }

  @override
  String configurationModes(String assistance, String investigation) {
    return '$assistance assistance • $investigation investigation';
  }

  @override
  String get openCityFile => 'Open City File';

  @override
  String get pressureStable => 'Stable';

  @override
  String get pressureStableDescription =>
      'Services are holding, but important weaknesses still need attention.';

  @override
  String get pressureStrained => 'Strained';

  @override
  String get pressureStrainedDescription =>
      'Several systems are under pressure and difficult choices are already due.';

  @override
  String get pressureCrisis => 'Crisis';

  @override
  String get pressureCrisisDescription =>
      'The city begins with severe problems, low breathing room, and urgent risks.';

  @override
  String get concernFood => 'Food security';

  @override
  String get concernFoodDescription => 'Food prices and access';

  @override
  String get concernPoverty => 'Poverty';

  @override
  String get concernPovertyDescription => 'Families falling behind';

  @override
  String get concernHealth => 'Public health';

  @override
  String get concernHealthDescription => 'Clinics and community care';

  @override
  String get concernEducation => 'Education';

  @override
  String get concernEducationDescription => 'Schools and learning access';

  @override
  String get concernWater => 'Water';

  @override
  String get concernWaterDescription => 'Safe and reliable water';

  @override
  String get concernJobs => 'Jobs';

  @override
  String get concernJobsDescription => 'Employment and working conditions';

  @override
  String get concernServices => 'Housing & transport';

  @override
  String get concernServicesDescription =>
      'Neighborhood and infrastructure strain';

  @override
  String get concernClimate => 'Climate';

  @override
  String get concernClimateDescription => 'Flood, heat, and disaster readiness';

  @override
  String get candidateUnproven => 'Unproven';

  @override
  String get candidateUnprovenDescription =>
      'Candidates have less governing experience and more uncertain delivery.';

  @override
  String get candidateMixed => 'Mixed';

  @override
  String get candidateMixedDescription =>
      'The field contains a broad mix of experience and operating skill.';

  @override
  String get candidateSeasoned => 'Seasoned';

  @override
  String get candidateSeasonedDescription =>
      'Candidates are generally more experienced, but still carry real tradeoffs.';

  @override
  String get assistanceGuided => 'Guided';

  @override
  String get assistanceGuidedDescription =>
      'Resi introduces new screens and offers neutral civic-learning reminders.';

  @override
  String get assistanceStandard => 'Standard';

  @override
  String get assistanceStandardDescription =>
      'No automatic guidance. The Guide button remains available whenever needed.';

  @override
  String get noiseClear => 'Clear';

  @override
  String get noiseClearDescription =>
      'Official records and accountable sources are easier to find first.';

  @override
  String get noiseTypical => 'Typical';

  @override
  String get noiseTypicalDescription =>
      'Campaign material, records, posts, and fact-checks arrive in a normal mix.';

  @override
  String get noiseNoisy => 'Noisy';

  @override
  String get noiseNoisyDescription =>
      'Extra rumors and attention-grabbing posts compete with stronger evidence.';

  @override
  String get investigationRelaxed => 'Relaxed';

  @override
  String get investigationRelaxedDescription =>
      'Open as many evidence files as you want.';

  @override
  String get investigationStandard => 'Standard';

  @override
  String get investigationStandardDescription =>
      'You have 12 investigation points. Candidate profiles are free.';

  @override
  String get investigationLimited => 'Limited';

  @override
  String get investigationLimitedDescription =>
      'You have 7 investigation points. Candidate profiles are free.';

  @override
  String get electionBrief => 'Election brief';

  @override
  String get cityBeforeVote => 'The city before the vote';

  @override
  String get guidedReminderTitle => 'Resi\'s neutral reminder';

  @override
  String get guidedReminderBody =>
      'Start with the city\'s urgent files, then compare candidate evidence before deciding.';

  @override
  String get urgentCaseFiles => 'Urgent case files';

  @override
  String get cityCondition => 'City condition';

  @override
  String get meetCandidates => 'Meet the candidates';

  @override
  String get cityImageSemantics =>
      'An illustrated civic hall, waterfront, water infrastructure, clinic, school, and market district.';

  @override
  String get cityHubTitle => 'City brief';

  @override
  String get preElectionSnapshot => 'Pre-election snapshot';

  @override
  String get preElectionFrozenNote =>
      'Background context only. The city does not advance and consequential events do not begin until your vote is confirmed.';

  @override
  String get cityPulse => 'City pulse';

  @override
  String get fictionalCityEstimate =>
      'Fictional city estimate derived from the starting scenario';

  @override
  String get urgentConcerns => 'Concerns on the ballot';

  @override
  String affectedResidentsEstimate(int percent) {
    return '$percent% estimated residents affected';
  }

  @override
  String severityValue(String value) {
    return 'Severity: $value';
  }

  @override
  String urgencyValue(String value) {
    return 'Urgency: $value';
  }

  @override
  String get openCaseFile => 'Open case file';

  @override
  String get caseFileDetails => 'Concern details';

  @override
  String get relatedIndicators => 'Related city systems';

  @override
  String get currentCondition => 'Current condition';

  @override
  String get latestChronicle => 'Latest from the Chronicle';

  @override
  String get openChronicle => 'Open Chronicle';

  @override
  String get chronicleTitle => 'City Chronicle';

  @override
  String get chronicleIntro =>
      'Background reporting and sampled resident voices describe the city at the start of the election. This feed is not an advancing simulation.';

  @override
  String get cityNews => 'City news';

  @override
  String get communityVoices => 'Community voices';

  @override
  String get voiceSampleNote =>
      'These are fictional sampled perspectives, not a scientific poll or the voice of the entire city.';

  @override
  String get backgroundContextLabel => 'Background context';

  @override
  String get unverifiedClaim => 'Unverified community claim';

  @override
  String get navCity => 'City';

  @override
  String get navDossiers => 'Dossiers';

  @override
  String get navChronicle => 'Chronicle';

  @override
  String get cityMapHint => 'Tap a city marker to open its concern file.';

  @override
  String get candidateRoster => 'Candidate roster';

  @override
  String get candidateRosterHeading => 'Three imperfect choices';

  @override
  String get candidateRosterIntro =>
      'No score is shown and no candidate is recommended. Open every dossier, compare evidence, and decide which tradeoffs you can defend.';

  @override
  String get visibleStrengths => 'Visible strengths';

  @override
  String get visibleConcerns => 'Visible concerns';

  @override
  String get openDossier => 'Open dossier';

  @override
  String get proceedElection => 'Proceed to election day';

  @override
  String get dossier => 'Dossier';

  @override
  String get electionDay => 'Election day';

  @override
  String get documentedStrengths => 'Documented strengths';

  @override
  String get questionsToInvestigate => 'Questions to investigate';

  @override
  String get campaignPlatform => 'Campaign platform';

  @override
  String get evidenceDesk => 'Evidence desk';

  @override
  String bookmarkedCount(int count) {
    return '$count bookmarked';
  }

  @override
  String get evidenceDeskHint =>
      'A source can be reputable yet incomplete. Open the item before deciding what weight it deserves.';

  @override
  String get sourceDesk => 'Source Desk';

  @override
  String get sourceDeskDefault => 'Use the original dossier order.';

  @override
  String get sourceDeskOrganized =>
      'Bookmarked and reviewed files are grouped first, then by source type.';

  @override
  String investigationPointsRemaining(int count) {
    return '$count investigation points remaining';
  }

  @override
  String get roster => 'Roster';

  @override
  String get reviewBallot => 'Review ballot';

  @override
  String get noInvestigationPoints => 'No investigation points left';

  @override
  String get noInvestigationPointsBody =>
      'You have used the investigation time chosen for this city. Previously opened evidence remains available.';

  @override
  String sourceCue(String cue) {
    return 'Source cue: $cue';
  }

  @override
  String factCheckFinding(String finding) {
    return 'Fact-check finding: $finding';
  }

  @override
  String get bookmark => 'Bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get reliabilityStrong => 'strong documentary support';

  @override
  String get reliabilityModerate => 'useful but verify context';

  @override
  String get reliabilityWeak => 'weak or interested source';

  @override
  String get overviewTab => 'Overview';

  @override
  String get platformTab => 'Platform';

  @override
  String get evidenceTab => 'Evidence';

  @override
  String get allEvidence => 'All files';

  @override
  String get recordsEvidence => 'Records';

  @override
  String get campaignEvidence => 'Campaign';

  @override
  String get publicClaimsEvidence => 'Public claims';

  @override
  String get factChecksEvidence => 'Fact-checks';

  @override
  String get debateEvidence => 'Debate';

  @override
  String get questionsEvidence => 'Questions';

  @override
  String get bookmarkedEvidence => 'Bookmarked';

  @override
  String get fileOpened => 'Opened';

  @override
  String get fileUnopened => 'Unopened';

  @override
  String get fileFree => 'Free profile';

  @override
  String get filePointCost => '1 point';

  @override
  String filesReviewed(int opened, int total) {
    return '$opened / $total files reviewed';
  }

  @override
  String get candidateForMayor => 'For mayor';

  @override
  String get biography => 'Biography';

  @override
  String get platformReminder =>
      'Promises show intent. Check records, funding, and delivery before giving them weight.';

  @override
  String get noEvidenceInFilter => 'No files match this filter yet.';

  @override
  String get sourceCheckTitle => 'Check the receipt';

  @override
  String get sourceCheckBody =>
      'Ask who produced this, what proof it gives, what context may be missing, and whether another source confirms it.';

  @override
  String get openEvidence => 'Open file';

  @override
  String get unlimitedInvestigation => 'Unlimited investigation';

  @override
  String get previousCandidate => 'Previous candidate';

  @override
  String get nextCandidate => 'Next candidate';

  @override
  String get recordSnapshot => 'Record snapshot';

  @override
  String get publicServiceExperience => 'Public-service experience';

  @override
  String get evidenceRecordDepth => 'Documented record';

  @override
  String get experienceEmerging => 'Emerging record';

  @override
  String get experiencePracticed => 'Practiced record';

  @override
  String get experienceEstablished => 'Established record';

  @override
  String get evidenceDepthLimited => 'Limited documentation';

  @override
  String get evidenceDepthMixed => 'Mixed documentation';

  @override
  String get evidenceDepthDocumented => 'Broad documentation';

  @override
  String accountableRecordsCount(int count) {
    return '$count accountable records';
  }

  @override
  String unresolvedFilesCount(int count) {
    return '$count unresolved files';
  }

  @override
  String distinctSourcesCount(int count) {
    return '$count distinct sources';
  }

  @override
  String get electionDayHeading => 'Choose without a match score';

  @override
  String get ballotInstruction =>
      'Review the evidence, choose one imperfect candidate, and record what shaped your decision.';

  @override
  String get ballotCandidateInstruction => 'Select a candidate for mayor';

  @override
  String get ballotSelected => 'Selected for your ballot';

  @override
  String get choosePriority => 'Choose the issue that mattered most';

  @override
  String get confidenceReflection => 'Confidence is a reflection, not a score.';

  @override
  String evidenceOpenedCount(int opened, int total) {
    return '$opened of $total evidence items opened. Investigation completeness is context, not a score.';
  }

  @override
  String get viewDossier => 'Dossier';

  @override
  String get topIssueQuestion =>
      'Which city problem matters most to your decision?';

  @override
  String get confidenceQuestion => 'How confident are you in this choice?';

  @override
  String confidenceValue(int value) {
    return '$value%';
  }

  @override
  String get confidenceLow => 'Still uncertain';

  @override
  String get confidenceHigh => 'Very confident';

  @override
  String get castVote => 'Cast vote';

  @override
  String get sealBallotQuestion => 'Seal this ballot?';

  @override
  String sealBallotBody(String candidate) {
    return 'You are choosing $candidate. The term simulation will reveal consequences, not a verdict about the correct vote.';
  }

  @override
  String get keepReviewing => 'Keep reviewing';

  @override
  String get confirmVote => 'Confirm vote';

  @override
  String get winnerDeclared => 'Election result';

  @override
  String nowGovernsCity(String candidate, String city) {
    return '$candidate now governs $city.';
  }

  @override
  String get beginTerm => 'Begin the term';

  @override
  String get returnToBallot => 'Return to ballot';

  @override
  String get termInProgress => 'Term in progress';

  @override
  String get termTimeline => 'Administration timeline';

  @override
  String phaseProgress(int current, int total) {
    return '$current of $total phases revealed';
  }

  @override
  String get currentCityCondition => 'Current city condition';

  @override
  String get majorEvent => 'Major city event';

  @override
  String get cityUpdate => 'City update';

  @override
  String get eventImpact => 'Recorded impact';

  @override
  String get advanceTerm => 'Advance the term';

  @override
  String get termReady => 'The term record is complete';

  @override
  String get termSimulationHeading => 'One term, four explainable phases';

  @override
  String get termSimulationIntro =>
      'The same seed and candidate always produce the same result. Each change identifies the factors that shaped it.';

  @override
  String phaseNumber(int number) {
    return 'Phase $number';
  }

  @override
  String changeValue(String indicator, String change) {
    return '$indicator: $change';
  }

  @override
  String get viewTermReport => 'View term report';

  @override
  String get termReport => 'Term report';

  @override
  String administrationOf(String candidate) {
    return 'The $candidate administration';
  }

  @override
  String get before => 'Before';

  @override
  String get after => 'After';

  @override
  String get change => 'Change';

  @override
  String get whyThisHappened => 'Why this happened';

  @override
  String get modelExplanation =>
      'The deterministic model selected major events from the city seed, active concerns, and starting weaknesses. Their impact combined relevant policy knowledge, implementation, crisis response, integrity, coalition support, budget feasibility, and a logged ±10% seeded variation. Hidden scores were never used as pre-election hints.';

  @override
  String get yourDecisionContext => 'Your decision context';

  @override
  String decisionContextBody(String issue, int confidence, int evidence) {
    return 'Top issue: $issue • Confidence: $confidence% • Evidence opened: $evidence';
  }

  @override
  String get notRecorded => 'Not recorded';

  @override
  String replaySeed(int seed) {
    return 'Replay seed $seed';
  }

  @override
  String continueToNextElection(int term) {
    return 'Continue to Election $term';
  }

  @override
  String get nextElectionDescription =>
      'Carry this city\'s results forward. The next campaign inherits its indicators, unresolved issues, and political history.';

  @override
  String get caseFileMissing => 'That case file could not be found.';

  @override
  String get returnHome => 'Return home';

  @override
  String get indicatorFoodSecurity => 'Food security';

  @override
  String get indicatorPovertyReduction => 'Poverty reduction';

  @override
  String get indicatorPublicHealth => 'Public health';

  @override
  String get indicatorEducationQuality => 'Education quality';

  @override
  String get indicatorWaterSecurity => 'Water security';

  @override
  String get indicatorEmploymentQuality => 'Employment quality';

  @override
  String get indicatorUrbanResilience => 'Urban resilience';

  @override
  String get indicatorClimateResilience => 'Climate resilience';

  @override
  String get indicatorBudgetHealth => 'Budget health';

  @override
  String get indicatorPublicTrust => 'Public trust';

  @override
  String get indicatorCorruptionPressure => 'Corruption pressure';

  @override
  String get stateCritical => 'Critical';

  @override
  String get statePoor => 'Poor';

  @override
  String get stateUnstable => 'Unstable';

  @override
  String get stateFunctional => 'Functional';

  @override
  String get stateStrong => 'Strong';

  @override
  String get trendImproving => 'Improving';

  @override
  String get trendStable => 'Stable';

  @override
  String get trendWorsening => 'Worsening';

  @override
  String get trendRapidlyWorsening => 'Rapidly worsening';

  @override
  String get evidenceProfile => 'Profile';

  @override
  String get evidencePlatform => 'Platform';

  @override
  String get evidenceCampaignAd => 'Campaign ad';

  @override
  String get evidencePublicRecord => 'Public record';

  @override
  String get evidenceBudgetDocument => 'Budget document';

  @override
  String get evidenceSocialPost => 'Social post';

  @override
  String get evidenceFactCheck => 'Fact-check';

  @override
  String get evidenceControversy => 'Controversy';

  @override
  String get evidenceDebateAnswer => 'Debate answer';

  @override
  String get truthVerified => 'Verified';

  @override
  String get truthMostlyTrue => 'Mostly true';

  @override
  String get truthPartiallyTrue => 'Partially true';

  @override
  String get truthMisleading => 'Misleading';

  @override
  String get truthUnverified => 'Unverified';

  @override
  String get truthFalse => 'False';

  @override
  String get truthMissingContext => 'Missing context';

  @override
  String get selectedCandidateEffectTitle =>
      'Your selected candidate becomes the administration.';

  @override
  String get selectedCandidateEffectBody =>
      'The report explains consequences; it will not label your vote right or wrong.';

  @override
  String get administrationReceipt => 'Administration receipt';

  @override
  String get administrationTimeline => 'What happened during the term';

  @override
  String get strongestGains => 'Strongest gains';

  @override
  String get hardestSetbacks => 'Hardest setbacks';

  @override
  String get outcomeNotVerdict =>
      'This is a record of consequences, not a verdict that your vote was right or wrong.';

  @override
  String get noMajorChange => 'No major movement';

  @override
  String get whatChanged => 'What changed';

  @override
  String get whatChangedBody =>
      'Labels show final condition. Signed values show movement during the term; corruption pressure is healthier when it falls.';

  @override
  String advanceToPhase(int number) {
    return 'Advance to phase $number';
  }

  @override
  String get savedOnDevice => 'Saved on this device';

  @override
  String get savingCityFiles => 'Saving city files…';

  @override
  String get citySaveProblem =>
      'City files could not be saved. Your current session remains open.';

  @override
  String get retrySave => 'Retry saving';

  @override
  String get politicalHistory => 'Political history';

  @override
  String get openPoliticalHistory => 'Open political history';

  @override
  String politicalHistoryDescription(int count) {
    return 'Review $count completed administration record(s), including city outcomes, projects, major events, and your election receipts.';
  }

  @override
  String get historicalReceipt => 'Historical receipt';

  @override
  String get historicalReceiptMissing =>
      'That administration record is not stored in this city.';

  @override
  String get noAdministrationHistory => 'No completed administrations yet';

  @override
  String historyBeginsAfterTerm(int term) {
    return 'Political history begins after Administration $term is completed and the city continues to its next election.';
  }

  @override
  String get cityPoliticalTimeline => 'The city\'s political timeline';

  @override
  String historyTimelineDescription(int count, int election) {
    return '$count administration(s) are sealed in the record. The city is now preparing for Election $election.';
  }

  @override
  String administrationNumber(int term) {
    return 'Administration $term';
  }

  @override
  String openAdministrationReceipt(int term) {
    return 'Open the receipt for Administration $term';
  }

  @override
  String projectsCompleted(int count) {
    return '$count completed';
  }

  @override
  String majorEvents(int count) {
    return '$count major events';
  }

  @override
  String get openHistoricalReceipt => 'Open the full term receipt';

  @override
  String get cityOutcome => 'City outcome';

  @override
  String get promiseProjectRecord => 'Promise and project record';

  @override
  String get majorEventsRecorded => 'Major events recorded';

  @override
  String get noMajorEventsRecorded =>
      'No major event was marked in this administration.';

  @override
  String get electionReceipt => 'Election receipt';

  @override
  String administrationOutcome(int term, String condition) {
    return 'Administration $term ended with the city rated $condition.';
  }

  @override
  String projectProgressReceipt(int progress, int milestones) {
    return '$progress% complete · $milestones recorded milestone(s)';
  }

  @override
  String get candidatesOnBallot => 'Candidates on ballot';

  @override
  String get evidenceReviewed => 'Evidence reviewed';

  @override
  String get receiptsSaved => 'Receipts saved';

  @override
  String get topIssueRecorded => 'Top issue recorded';

  @override
  String get voterConfidence => 'Voter confidence';

  @override
  String get resiboNgBayan => 'Resibo ng Bayan';

  @override
  String get openResiboNgBayan => 'Open Resibo ng Bayan';

  @override
  String get publicAccountabilityJournal => 'Public accountability journal';

  @override
  String get accountabilityJournalDescription =>
      'Campaign promises are matched with the sealed project record. Incomplete work is described by its recorded state, not automatically called a lie.';

  @override
  String get promisesRecorded => 'Promises recorded';

  @override
  String get deliveredLabel => 'Delivered';

  @override
  String get administrationsRecorded => 'Administrations';

  @override
  String get allPromises => 'All promises';

  @override
  String get unresolvedPromises => 'Unresolved';

  @override
  String get noHistoricalPromises =>
      'Complete an administration to begin the public promise journal.';

  @override
  String get noPromisesInFilter => 'No promises match this filter.';

  @override
  String get promiseNotStarted => 'Not started';

  @override
  String get promiseInProgress => 'In progress';

  @override
  String get promisePartiallyDelivered => 'Partially delivered';

  @override
  String get promiseDelivered => 'Delivered';

  @override
  String get promiseDelayed => 'Delayed';

  @override
  String get promiseAbandoned => 'Abandoned';

  @override
  String get promiseBlocked => 'Blocked';

  @override
  String get civicPredictions => 'Your expectations';

  @override
  String get civicPredictionsPrompt =>
      'Optionally record up to two expectations before you seal the ballot.';

  @override
  String get civicPredictionsNote =>
      'These are reflection notes, not bets or a hidden score. The term report will compare them with observed city indicators.';

  @override
  String predictionsSelected(int count) {
    return '$count of 2 expectations recorded';
  }

  @override
  String get predictionHealth => 'Public health will improve';

  @override
  String get predictionHealthDescription =>
      'Compare the final public-health indicator with its starting condition.';

  @override
  String get predictionInfrastructure =>
      'Infrastructure resilience will improve';

  @override
  String get predictionInfrastructureDescription =>
      'Compare water, urban, and climate resilience across the term.';

  @override
  String get predictionLivelihoods => 'Livelihood conditions will improve';

  @override
  String get predictionLivelihoodsDescription =>
      'Compare employment quality and poverty reduction.';

  @override
  String get predictionBudget => 'The city budget will remain healthier';

  @override
  String get predictionBudgetDescription =>
      'Compare final budget health with the start of the term.';

  @override
  String get predictionTrust => 'Public trust will improve';

  @override
  String get predictionTrustDescription =>
      'Compare public trust before and after the administration.';

  @override
  String get predictionCorruption => 'Corruption pressure will fall';

  @override
  String get predictionCorruptionDescription =>
      'A lower final corruption-pressure indicator is healthier.';

  @override
  String get predictionReflection => 'Your expectation receipt';

  @override
  String get predictionReflectionBody =>
      'This compares what you recorded before voting with observed indicator movement. It does not grade the vote or reveal a correct candidate.';

  @override
  String get predictionObserved => 'Observed improvement';

  @override
  String get predictionMixed => 'Mixed result';

  @override
  String get predictionNotObserved => 'Not observed';

  @override
  String get historicalEvidence => 'Historical evidence';

  @override
  String get historicalEvidenceMissing =>
      'That evidence item is not present in the archived election snapshot.';

  @override
  String get archivedElectionSnapshot => 'Sealed election snapshot';

  @override
  String get historicalEvidenceNotice =>
      'This is the evidence snapshot stored with that election. Later campaigns cannot replace or rewrite this historical document.';

  @override
  String get openArchivedEvidence => 'Open archived evidence';

  @override
  String get recurringRecords => 'Recurring records';

  @override
  String get recurringRecordsDescription =>
      'These patterns come from multiple sealed administrations. Repetition provides context; it is not automatic proof of honesty, guilt, or future performance.';

  @override
  String get repeatedPromise => 'Repeated promise area';

  @override
  String get recurringControversy => 'Recurring controversy';

  @override
  String administrationsList(String terms) {
    return 'Administrations: $terms';
  }

  @override
  String get citizenActions => 'Citizen Actions';

  @override
  String get citizenActionHubDescription =>
      'You are a citizen, not the mayor. Take limited actions during this term; the administration may cooperate, compromise, or resist.';

  @override
  String get requestPublicRecords => 'Request Public Records';

  @override
  String get requestPublicRecordsDescription =>
      'Ask City Hall to release records relevant to public accountability.';

  @override
  String get organizePetition => 'Organize a Petition';

  @override
  String get organizePetitionDescription =>
      'Build public pressure around the city\'s most severe current concern.';

  @override
  String get challengeMisleadingClaim => 'Challenge a Misleading Claim';

  @override
  String get challengeMisleadingClaimDescription =>
      'Use reviewed evidence to challenge a misleading or false public claim.';

  @override
  String get challengeEvidenceRequired =>
      'Review a reliable fact-check, public record, budget document, or documented controversy during the election to unlock this action.';

  @override
  String challengeEvidenceSelected(String title) {
    return 'Supporting reviewed evidence: $title';
  }

  @override
  String get actionWindowNotice =>
      'Actions become available on Day 30 and close after Day 350.';

  @override
  String get actionAlreadyUsed => 'Filed this term';

  @override
  String get actionUnavailable => 'Unavailable right now';

  @override
  String get takeCitizenAction => 'Take action';

  @override
  String get actionPending => 'Pending response';

  @override
  String get actionResolved => 'Outcome recorded';

  @override
  String actionOutcomeDay(int day) {
    return 'Expected response: Day $day';
  }

  @override
  String get actionFiledConfirmation =>
      'Action filed. Its outcome is now part of this term\'s fixed future.';

  @override
  String get citizenActionCausalityNote =>
      'Outcome depends on city conditions, issue difficulty, public trust, budget health, and the mayor\'s capabilities. Success is not guaranteed.';

  @override
  String get confirmCitizenAction => 'Confirm citizen action?';

  @override
  String get confirmCitizenActionBody =>
      'This action can be used only once this term. Its deterministic outcome will occur later and will persist with the save.';

  @override
  String get cancelAction => 'Not now';

  @override
  String get confirmAction => 'File action';

  @override
  String get civicProfile => 'Civic Profile';

  @override
  String get openCivicProfile => 'Open Civic Profile';

  @override
  String get civicProfileCityDescription =>
      'Track civic practice and long-term accomplishments without exposing hidden candidate scores.';

  @override
  String get civicProfileSubtitle => 'Your long-term civic record';

  @override
  String get civicGrowthExplanation =>
      'Progress comes from unique investigation, accountability work, citizen action, and completed administrations. It improves civic tools—not politicians—and never reveals hidden candidate truth.';

  @override
  String get civicTracks => 'Civic practice';

  @override
  String civicLevel(int level) {
    return 'Level $level';
  }

  @override
  String civicPoints(int points) {
    return '$points record points';
  }

  @override
  String civicNextLevel(int points) {
    return '$points to next level';
  }

  @override
  String get civicMaxLevel => 'Maximum level reached';

  @override
  String get researchTrack => 'Research';

  @override
  String get researchTrackDescription =>
      'Review and organize evidence across distinct elections.';

  @override
  String get accountabilityTrack => 'Public Accountability';

  @override
  String get accountabilityTrackDescription =>
      'Keep receipts, request records, and document recurring concerns.';

  @override
  String get organizingTrack => 'Civic Organizing';

  @override
  String get organizingTrackDescription =>
      'Build experience through limited petitions and continued participation.';

  @override
  String get historyTrack => 'Historical Analysis';

  @override
  String get historyTrackDescription =>
      'Complete administrations and connect recurring political records.';

  @override
  String responseEfficiencyUnlocked(int days) {
    return 'Civic experience shortens this action\'s response time by $days days without improving its chance of success.';
  }

  @override
  String get sourceDeskUnlocked =>
      'Source Desk unlocked: optionally organize visible dossier files by review state and source type. It does not reveal hidden truth or unlock evidence.';

  @override
  String get civicAccomplishments => 'Accomplishments';

  @override
  String civicAccomplishmentsCount(int done, int total) {
    return '$done of $total documented';
  }

  @override
  String get accomplishmentFirstAdministration => 'A City Remembers';

  @override
  String get accomplishmentFirstAdministrationDescription =>
      'Complete and archive one administration.';

  @override
  String get accomplishmentThreeAdministrations => 'Three Elections Later';

  @override
  String get accomplishmentThreeAdministrationsDescription =>
      'Complete three administrations in the same city.';

  @override
  String get accomplishmentFiveAdministrations => 'Long Civic Memory';

  @override
  String get accomplishmentFiveAdministrationsDescription =>
      'Complete five administrations in the same city.';

  @override
  String get accomplishmentMultiSource => 'Check More Than One Source';

  @override
  String get accomplishmentMultiSourceDescription =>
      'Review at least five evidence items in one election.';

  @override
  String get accomplishmentRecurringPromise => 'Promise, Repeated';

  @override
  String get accomplishmentRecurringPromiseDescription =>
      'Document a recurring promise across sealed administrations.';

  @override
  String get accomplishmentPublicRecords => 'Records Obtained';

  @override
  String get accomplishmentPublicRecordsDescription =>
      'Receive a useful or partial public-record release.';

  @override
  String get accomplishmentPetition => 'A Public Response';

  @override
  String get accomplishmentPetitionDescription =>
      'Organize a petition that produces a recorded concession or response.';

  @override
  String get accomplishmentIssueRecovery => 'Signs of Recovery';

  @override
  String get accomplishmentIssueRecoveryDescription =>
      'See a major city issue improve substantially during a term.';

  @override
  String get accomplishmentCrossTermProject => 'Across Administrations';

  @override
  String get accomplishmentCrossTermProjectDescription =>
      'Track work in the same issue family across multiple terms.';

  @override
  String get accomplishmentPoliticalComeback => 'The Comeback';

  @override
  String get accomplishmentPoliticalComebackDescription =>
      'Witness a former mayor return after at least one administration away.';
}
