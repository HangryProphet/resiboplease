import 'package:flutter/widgets.dart';

import '../domain/models/candidate_biography.dart';
import '../domain/models/candidate_experience.dart';
import '../domain/models/city_problem.dart';

extension CandidateExperienceLocalization on BuildContext {
  CandidateExperienceStrings get candidateStrings =>
      CandidateExperienceStrings(Localizations.localeOf(this).languageCode);
}

class CandidateExperienceStrings {
  const CandidateExperienceStrings(this.languageCode);

  final String languageCode;
  bool get isFilipino => languageCode == 'fil';

  String get campaignHub => isFilipino ? 'Campaign Hub' : 'Campaign Hub';
  String get pulse => isFilipino ? 'Pulso' : 'Pulse';
  String get bio => isFilipino ? 'Biyograpiya' : 'Bio';
  String get promises => isFilipino ? 'Mga Pangako' : 'Promises';
  String get records => isFilipino ? 'Mga Rekord' : 'Records';
  String get dossier => isFilipino ? 'Dossier' : 'Dossier';
  String get debate => isFilipino ? 'Debate' : 'Debate';
  String get receipts => isFilipino ? 'Mga Resibo' : 'Receipts';
  String get receiptsBoard =>
      isFilipino ? 'Pisara ng mga Resibo' : 'Receipts Board';
  String get unresolvedQuestions =>
      isFilipino ? 'Mga Tanong na Hindi Pa Sagot' : 'Unresolved Questions';
  String get publicIdentity =>
      isFilipino ? 'Pampublikong Pagkakakilanlan' : 'Public Identity';
  String get campaignPulse =>
      isFilipino ? 'Pulso ng Kampanya' : 'Campaign Pulse';
  String get campaignPulseIntro => isFilipino
      ? 'Mabilis na tingin sa mga pangako, balita, depensa, at kontradiksyon.'
      : 'A quick read of promises, news, defenses, and contradictions.';
  String get openDetails => isFilipino ? 'Suriin' : 'Inspect';
  String get closeDetails => isFilipino ? 'Isara' : 'Close';
  String get deepDive => isFilipino ? 'Malalim na Suri' : 'Deep Dive';
  String get relatedReceipts =>
      isFilipino ? 'Kaugnay na Resibo' : 'Related Receipts';
  String get candidateResponse =>
      isFilipino ? 'Sagot ng Kandidato' : 'Candidate Response';
  String get missingContext =>
      isFilipino ? 'Nawawalang Konteksto' : 'Missing Context';
  String get keyFigures => isFilipino ? 'Mahahalagang Bilang' : 'Key Figures';
  String get source => isFilipino ? 'Pinagmulan' : 'Source';
  String get publicAttention =>
      isFilipino ? 'Atensyon ng Publiko' : 'Public Attention';
  String get pinCandidate =>
      isFilipino ? 'I-pin ang kandidato' : 'Pin candidate';
  String get unpinCandidate =>
      isFilipino ? 'Alisin ang pin' : 'Unpin candidate';
  String get pinReceipt =>
      isFilipino ? 'I-pin bilang resibo' : 'Pin as receipt';
  String get unpinReceipt => isFilipino ? 'Alisin sa resibo' : 'Remove receipt';
  String get bookmarkStatement =>
      isFilipino ? 'I-bookmark ang pahayag' : 'Bookmark statement';
  String get suspicious => isFilipino ? 'Kahina-hinala' : 'Suspicious';
  String get markQuestion =>
      isFilipino ? 'I-pin ang bukas na tanong' : 'Pin unresolved question';
  String get openQuestion =>
      isFilipino ? 'Bukas na Tanong' : 'Unresolved Question';
  String get questionReceiptSummary => isFilipino
      ? 'Bukas pa ang tanong na ito. Suriin ang mga kaugnay na rekord bago bumoto.'
      : 'This question remains open. Review its linked records before voting.';
  String get compare => isFilipino ? 'Ihambing' : 'Compare';
  String get openArchive =>
      isFilipino ? 'Buksan ang Buong Dossier' : 'Open Full Dossier';
  String get dossierIntro => isFilipino
      ? 'Basahin ang buod, plataporma, at nakaayos na ebidensya.'
      : 'Read the overview, platform, and organized evidence archive.';
  String get debateStage => isFilipino ? 'Entablado ng Debate' : 'Debate Stage';
  String get debateIntro => isFilipino
      ? 'Tatlong usapin, mga sagot, sagutan, at mga kaugnay na rekord.'
      : 'Three issues, direct answers, rebuttals, and linked records.';
  String get moderator => isFilipino ? 'Tagapamagitan' : 'Moderator';
  String get recordDesk => isFilipino ? 'Talaan ng Rekord' : 'Record Desk';
  String get publicReaction =>
      isFilipino ? 'Reaksyon ng publiko' : 'Public reaction';
  String get openEvidence =>
      isFilipino ? 'Buksan ang ebidensya' : 'Open evidence';
  String get openCitation => isFilipino ? 'Buksan ang sipi' : 'Open citation';
  String get privateNote => isFilipino ? 'Pribadong Tala' : 'Private Note';
  String get saveNote => isFilipino ? 'I-save ang Tala' : 'Save Note';
  String get addNote => isFilipino ? 'Magdagdag ng tala' : 'Add a note';
  String get noReceipts => isFilipino
      ? 'Wala pang naka-pin na resibo. Mag-pin mula sa Pulse, Debate, o Dossier.'
      : 'No receipts pinned yet. Pin items from Pulse, Debate, or the Dossier.';
  String get allIssues => isFilipino ? 'Lahat ng Isyu' : 'All Issues';
  String get evidenceBookmarks =>
      isFilipino ? 'Naka-bookmark na Ebidensya' : 'Evidence Bookmarks';
  String get pulseReceipts =>
      isFilipino ? 'Mga Resibo sa Pulso' : 'Pulse Receipts';
  String get debateReceipts =>
      isFilipino ? 'Mga Resibo sa Debate' : 'Debate Receipts';
  String get sourceRelations =>
      isFilipino ? 'Mga Ugnayan ng Ebidensya' : 'Evidence Connections';
  String get civicArchive =>
      isFilipino ? 'Talaanang Sibiko ng Bayhaven' : 'Bayhaven Civic Archive';
  String get archiveIntro => isFilipino
      ? 'Isang sangguniang tala mula sa pampublikong rekord. Buksan ang mga sipi upang timbangin ang pinagmulan.'
      : 'A reference profile assembled from public records. Open citations to weigh the source.';
  String get biographyInfobox =>
      isFilipino ? 'Impormasyon' : 'Profile information';
  String get born => isFilipino ? 'Ipinanganak' : 'Born';
  String get age => isFilipino ? 'Edad' : 'Age';
  String get occupation => isFilipino ? 'Hanapbuhay' : 'Occupation';
  String get education => isFilipino ? 'Edukasyon' : 'Education';
  String get party => isFilipino ? 'Partido' : 'Party';
  String get currentPosition =>
      isFilipino ? 'Kasalukuyang katayuan' : 'Current position';
  String get yearsPublicService =>
      isFilipino ? 'Taon sa serbisyo publiko' : 'Years in public service';
  String get hometown => isFilipino ? 'Bayang pinagmulan' : 'Hometown';
  String get previousPositions =>
      isFilipino ? 'Mga dating posisyon' : 'Previous positions';
  String get careerTimeline =>
      isFilipino ? 'Takbo ng Karera' : 'Career timeline';
  String get article => isFilipino ? 'Artikulo' : 'Article';
  String get citationsAreReceipts => isFilipino
      ? 'Ang mga bilang na sipi ay nabubuksang resibo at maaaring gumamit ng investigation points.'
      : 'Numbered citations are openable receipts and may use investigation points.';
  String get promise => isFilipino ? 'Pangako' : 'Promise';
  String get proposedApproach =>
      isFilipino ? 'Iminungkahing paraan' : 'Proposed approach';
  String get relatedCityIssue =>
      isFilipino ? 'Kaugnay na suliranin ng lungsod' : 'Related city issue';
  String get complexity => isFilipino ? 'Saklaw' : 'Delivery scope';
  String get relatedPastRecord =>
      isFilipino ? 'Kaugnay na dating rekord' : 'Related past record';
  String get viewHistory => isFilipino ? 'Tingnan ang rekord' : 'View history';
  String get campaignTrail =>
      isFilipino ? 'Daloy ng Kampanya' : 'Campaign trail';
  String get thenLabel => isFilipino ? 'NOON' : 'THEN';
  String get nowLabel => isFilipino ? 'NGAYON' : 'NOW';
  String get viewContext =>
      isFilipino ? 'Tingnan ang konteksto' : 'View context';
  String get hideContext => isFilipino ? 'Itago ang konteksto' : 'Hide context';
  String get contextIsNotVerdict => isFilipino
      ? 'Ipinapakita nito ang pagbabago sa pahayag, hindi awtomatikong paghatol. Timbangin ang konteksto at resibo.'
      : 'This shows a change in statements, not an automatic verdict. Weigh the context and receipts.';
  String get relatedStatement =>
      isFilipino ? 'Kaugnay na pahayag' : 'Related statement';
  String get viewBiography =>
      isFilipino ? 'Tingnan ang biyograpiya' : 'View biography';
  String get relatedPromise =>
      isFilipino ? 'Kaugnay na pangako' : 'Related promise';
  String get referencedRecord =>
      isFilipino ? 'Tinukoy na rekord' : 'Referenced record';
  String get unlockedFollowUp =>
      isFilipino ? 'Libreng follow-up na nabuksan' : 'Free follow-up unlocked';
  String get free => isFilipino ? 'Libre' : 'Free';
  String points(int count) => isFilipino
      ? '$count puntos'
      : '$count ${count == 1 ? 'point' : 'points'}';
  String get noScoreReminder => isFilipino
      ? 'Walang match score o rekomendasyon. Timbangin ang mga resibo.'
      : 'No match score or recommendation. Weigh the receipts yourself.';
  String get compareCandidates =>
      isFilipino ? 'Ihambing ang mga Kandidato' : 'Compare Candidates';
  String get comparisonReminder => isFilipino
      ? 'Pampublikong impormasyon lamang—walang nakatagong marka.'
      : 'Public information only—no hidden ratings.';

  String styleLabel(CandidateRhetoricalStyle style) => switch (style) {
    CandidateRhetoricalStyle.technical => isFilipino ? 'Teknikal' : 'Technical',
    CandidateRhetoricalStyle.charismatic =>
      isFilipino ? 'Karismatiko' : 'Charismatic',
    CandidateRhetoricalStyle.storyDriven =>
      isFilipino ? 'Kuwento ang paraan' : 'Story-driven',
    CandidateRhetoricalStyle.aggressive =>
      isFilipino ? 'Agresibo' : 'Aggressive',
    CandidateRhetoricalStyle.calm => isFilipino ? 'Kalmado' : 'Calm',
    CandidateRhetoricalStyle.evasive => isFilipino ? 'Palaiwas' : 'Evasive',
    CandidateRhetoricalStyle.sarcastic =>
      isFilipino ? 'Mapanukso' : 'Sarcastic',
    CandidateRhetoricalStyle.emotional =>
      isFilipino ? 'Madamdamin' : 'Emotional',
    CandidateRhetoricalStyle.statisticHeavy =>
      isFilipino ? 'Puno ng estadistika' : 'Statistic-heavy',
    CandidateRhetoricalStyle.attackFocused =>
      isFilipino ? 'Nakatutok sa pag-atake' : 'Attack-focused',
    CandidateRhetoricalStyle.conciliatory =>
      isFilipino ? 'Mapagkasundo' : 'Conciliatory',
  };

  String complexityLabel(CandidatePromiseComplexity complexity) =>
      switch (complexity) {
        CandidatePromiseComplexity.focusedProgram =>
          isFilipino ? 'Tiyak na programa' : 'Focused program',
        CandidatePromiseComplexity.multiAgency =>
          isFilipino ? 'Maraming ahensya' : 'Multi-agency',
        CandidatePromiseComplexity.capitalProject =>
          isFilipino ? 'Malaking proyekto' : 'Capital project',
        CandidatePromiseComplexity.structuralReform =>
          isFilipino ? 'Pagbabagong estruktural' : 'Structural reform',
      };

  String issueFamilyLabel(CityIssueFamily family) => switch (family) {
    CityIssueFamily.floodingDrainage =>
      isFilipino ? 'Baha at drainage' : 'Flooding and drainage',
    CityIssueFamily.corruptionPublicFunds =>
      isFilipino ? 'Pondo at katiwalian' : 'Public funds and corruption',
    CityIssueFamily.unfinishedRoads =>
      isFilipino ? 'Mga kalsada' : 'Road delivery',
    CityIssueFamily.drugsCommunitySafety =>
      isFilipino ? 'Kaligtasan ng komunidad' : 'Community safety',
    CityIssueFamily.garbageCleanliness =>
      isFilipino ? 'Basura at kalinisan' : 'Waste and cleanliness',
    CityIssueFamily.trafficTransport =>
      isFilipino ? 'Trapiko at transportasyon' : 'Traffic and transport',
    CityIssueFamily.waterSupply =>
      isFilipino ? 'Suplay ng tubig' : 'Water supply',
    CityIssueFamily.healthcareCapacity =>
      isFilipino ? 'Serbisyong pangkalusugan' : 'Healthcare capacity',
    CityIssueFamily.employmentQuality =>
      isFilipino ? 'Kalidad ng trabaho' : 'Employment quality',
    CityIssueFamily.costOfLiving =>
      isFilipino ? 'Gastos sa pamumuhay' : 'Cost of living',
    CityIssueFamily.governmentServices =>
      isFilipino ? 'Serbisyo ng pamahalaan' : 'Government services',
    CityIssueFamily.educationCapacity =>
      isFilipino ? 'Kapasidad ng edukasyon' : 'Education capacity',
  };

  String reactionLabel(PublicReaction reaction) => switch (reaction) {
    PublicReaction.positive => isFilipino ? 'Pabor' : 'Positive',
    PublicReaction.mixed => isFilipino ? 'Halo-halo' : 'Mixed',
    PublicReaction.skeptical => isFilipino ? 'Mapagduda' : 'Skeptical',
    PublicReaction.negative => isFilipino ? 'Hindi pabor' : 'Negative',
    PublicReaction.surprised => isFilipino ? 'Nagulat' : 'Surprised',
  };

  String relationLabel(EvidenceRelationType type) => switch (type) {
    EvidenceRelationType.supports => isFilipino ? 'Sumusuporta' : 'Supports',
    EvidenceRelationType.contradicts =>
      isFilipino ? 'Sumasalungat' : 'Contradicts',
    EvidenceRelationType.addsContext =>
      isFilipino ? 'Dagdag na konteksto' : 'Adds context',
    EvidenceRelationType.updates => isFilipino ? 'Ina-update' : 'Updates',
    EvidenceRelationType.corrects => isFilipino ? 'Itinatama' : 'Corrects',
    EvidenceRelationType.disputes => isFilipino ? 'Kinukuwestiyon' : 'Disputes',
    EvidenceRelationType.references => isFilipino ? 'Tinutukoy' : 'References',
    EvidenceRelationType.revealsConsequence =>
      isFilipino ? 'Ipinapakita ang epekto' : 'Reveals consequence',
    EvidenceRelationType.exposesMissingInformation =>
      isFilipino ? 'Ipinapakita ang kulang' : 'Exposes missing information',
  };
}
