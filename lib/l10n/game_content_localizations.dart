import '../domain/models/candidate.dart';
import '../domain/models/city.dart';
import '../domain/models/city_problem.dart';
import '../domain/models/evidence_item.dart';
import '../domain/models/term_result.dart';
import 'app_localizations.dart';

extension LocalizedGameContent on AppLocalizations {
  bool get isFilipino => localeName.startsWith('fil');

  String citySummaryText(City city) {
    if (!isFilipino) return city.summary;
    final issues = city.problems
        .map((problem) => problemTitleText(problem).toLowerCase())
        .join(', ');
    return 'Sinisimulan ng ${city.name} ang halalang ito habang hinaharap ang $issues. Kailangang timbangin ng mga botante ang agarang tugon at pangmatagalang kakayahan.';
  }

  String problemTitleText(CityProblem problem) {
    if (!isFilipino) return problem.title;
    return switch (problem.id) {
      'food_costs' => 'Mas mabilis ang taas-presyo ng pagkain kaysa sahod',
      'households_falling_behind' => 'Mas maraming pamilyang naiiwan',
      'clinic_overload' => 'Siksikan ang mga pampublikong klinika',
      'schools_stretched_thin' => 'Kapos ang kapasidad ng mga paaralan',
      'water_contamination' =>
        'Hindi ligtas na tubig matapos ang malakas na ulan',
      'unemployment' => 'Hindi matatag na trabaho at tanggalan',
      'housing_transport_strain' => 'Problema sa pabahay at transportasyon',
      'climate_readiness' => 'Nahuhuli ang depensa laban sa baha',
      _ => problem.title,
    };
  }

  String problemDescriptionText(CityProblem problem, String cityName) {
    if (!isFilipino) return problem.description;
    return switch (problem.id) {
      'food_costs' =>
        'May mga pamilyang lumalaktaw ng pagkain dahil mas mabilis tumaas ang presyo sa pamilihan kaysa kita sa $cityName.',
      'households_falling_behind' =>
        'Dahil sa renta, pamasahe, at pagkain, mas maraming pamilya sa $cityName ang napupunta sa hindi matatag na kalagayan.',
      'clinic_overload' =>
        'Halos buong araw naghihintay ang mga pasyente dahil kulang ang kawani at suplay ng mga klinika sa $cityName.',
      'schools_stretched_thin' =>
        'Ang siksikang silid-aralan at hindi pantay na kagamitan ay nagpapalaki ng agwat sa pagkatuto sa $cityName.',
      'water_contamination' =>
        'Ilang distrito sa $cityName ang nag-uulat ng maruming tubig-gripo kapag nalulunod ng ulan ang sirang mga linya.',
      'unemployment' =>
        'Nagsasara ang mga negosyo sa $cityName habang panandalian at mababa ang sahod ng maraming bagong trabaho.',
      'housing_transport_strain' =>
        'Mahabang biyahe, alanganing pabahay, at mabagal na pagkukumpuni ang nagpapahirap sa araw-araw sa $cityName.',
      'climate_readiness' =>
        'Hindi makahabol ang drainage at planong pang-emergency ng $cityName sa mas malakas na ulan at mapanganib na init.',
      _ => problem.description,
    };
  }

  String candidatePartyText(Candidate candidate, String cityName) =>
      _candidateText(candidate.party, cityName);

  String candidateArchetypeText(Candidate candidate, String cityName) =>
      _candidateText(candidate.archetype, cityName);

  String candidateSloganText(Candidate candidate, String cityName) =>
      _candidateText(candidate.slogan, cityName);

  String candidateBiographyText(Candidate candidate, String cityName) =>
      _candidateText(candidate.biography, cityName);

  List<String> candidateStrengthsText(Candidate candidate, String cityName) =>
      candidate.visibleStrengths
          .map((value) => _candidateText(value, cityName))
          .toList(growable: false);

  List<String> candidateConcernsText(Candidate candidate, String cityName) =>
      candidate.visibleConcerns
          .map((value) => _candidateText(value, cityName))
          .toList(growable: false);

  List<String> candidatePlatformText(Candidate candidate, String cityName) =>
      candidate.platform
          .map((value) => _candidateText(value, cityName))
          .toList(growable: false);

  String evidenceTitleText(EvidenceItem item, String cityName) {
    if (!isFilipino) return item.title;
    if (item.title.endsWith(': profile')) {
      return '${item.title.substring(0, item.title.length - 9)}: profile';
    }
    return _candidateText(item.title, cityName);
  }

  String evidenceSourceText(EvidenceItem item, String cityName) =>
      _candidateText(item.source, cityName);

  String evidenceSummaryText(EvidenceItem item, String cityName) =>
      _candidateText(item.summary, cityName);

  String evidenceDetailsText(EvidenceItem item, String cityName) =>
      _candidateText(item.details, cityName);

  String phaseTitleText(TermPhase phase) {
    if (!isFilipino) return phase.title;
    return switch (phase.number) {
      1 => 'Ang unang isang daang araw',
      2 => 'Sinusubok ng ulan ang administrasyon',
      3 when phase.changes.values.any((value) => value >= 5) =>
        'Lumilitaw ang mga tanong sa kontrata',
      3 => 'Sinusuri ng publiko ang mga rekord',
      4 => 'Haharap sa pagpapatupad ang mga pangako',
      _ => phase.title,
    };
  }

  String phaseNarrativeText(TermPhase phase, Candidate candidate) {
    if (!isFilipino) return phase.narrative;
    return switch (phase.number) {
      1 =>
        'Itinuon ni ${candidate.name} ang unang malaking programa sa isa sa pinakamabigat na problema ng lungsod.',
      2 =>
        'Binaha ng tuloy-tuloy na ulan ang mabababang kalsada. Napigil ng mga emergency crew ang ilang pinsala, ngunit pumalya pa rin ang lumang mga sistema.',
      3 when phase.changes.values.any((value) => value >= 5) =>
        'Nasundan ng mga mamamahayag ang isang kontrata ng lungsod patungo sa mga kumpanyang may koneksiyong pampolitika. Nagpatuloy ang trabaho habang binubuksan ang imbestigasyon.',
      3 =>
        'Inilabas ang mga rekord sa procurement para sa pagsusuri. Kinukuwestiyon pa rin ng mga kritiko ang bilis ng pag-apruba ng konseho.',
      4 =>
        'Umabot sa dulo ng termino ang mga proyekto na may halong natapos na gawain, bahagyang solusyon, at hindi natupad na pangako.',
      _ => phase.narrative,
    };
  }

  String phaseExplanationText(TermPhase phase) {
    if (!isFilipino) return phase.explanation;
    return switch (phase.number) {
      1 =>
        'Ang maagang pagbuti ay mula sa kaalaman sa polisiya. Ang gastos sa badyet ay nakabatay sa pagkakapondo sa paglulunsad.',
      2 =>
        'Nababawasan ng mahusay na crisis response at kaalaman sa klima at tubig ang epekto ng bagyong nakatali sa seed.',
      3 =>
        'Hinuhubog ng integridad at panganib sa korupsiyon ang tagas ng yaman; naaapektuhan ng kakayahang bumuo ng koalisyon kung magdudulot ng tiwala ang transparency.',
      4 =>
        'Pinagsasama ng huling epekto ang bigat ng isyu, akma ng polisiya, pagpapatupad, integridad, suporta ng koalisyon, badyet, at seeded variation.',
      _ => phase.explanation,
    };
  }

  String termSummaryText(TermResult result) {
    if (!isFilipino) return result.summary;
    return switch (result.candidate.id) {
      'maya_vargas' =>
        'Gumanda ang access sa klinika at naging mas panatag ang mensahe sa krisis, ngunit lumiit ang puwang sa badyet dahil sa agresibong paggastos.',
      'julian_pratt' =>
        'Mabilis umusad ang mga programang pangtrabaho, ngunit nabawasan ang pakinabang dahil sa mga tanong sa kontrata at mahinang paghahanda sa baha.',
      'victor_chen' =>
        'Gumanda ang sistema ng tubig at pananagutan, ngunit pinabagal ng limitadong suporta sa konseho ang mas malawak na aksiyong pang-ekonomiya.',
      _ =>
        'May mga pakinabang at kapalit ang administrasyon ayon sa rekord nito at kalagayan ng lungsod.',
    };
  }

  String _candidateText(String value, String cityName) {
    if (!isFilipino) return value;
    final normalized = value.replaceAll(cityName, 'Bayhaven');
    final translated =
        _filipinoContent[normalized] ??
        (normalized.endsWith(' campaign')
            ? 'Kampanya ni ${normalized.substring(0, normalized.length - 9)}'
            : normalized);
    return translated.replaceAll('Bayhaven', cityName);
  }
}

const _filipinoContent = <String, String>{
  'Kalinga Civic Alliance': 'Alyansang Sibiko ng Kalinga',
  'Popular reformer': 'Popular na repormista',
  'Care that reaches every street.': 'Kalingang umaabot sa bawat kalye.',
  'A former community-health director who built mobile clinic partnerships across Bayhaven. Her coalition is young and energetic, but several large donors have interests in medical supply contracts.':
      'Dating direktor ng community health na bumuo ng mga katuwang na mobile clinic sa buong Bayhaven. Bata at masigla ang kaniyang koalisyon, ngunit may interes sa kontrata ng medical supply ang ilang malalaking donor.',
  'Deep public-health experience':
      'Malalim na karanasan sa pampublikong kalusugan',
  'Clear crisis communication': 'Malinaw makipagkomunika sa krisis',
  'Funding plan relies on optimistic revenue':
      'Umaasa sa optimistikong kita ang plano sa pondo',
  'Major campaign donors may create pressure':
      'Maaaring magdulot ng pressure ang malalaking donor',
  'Extend clinic hours and mobile care':
      'Palawigin ang oras ng klinika at mobile care',
  'Create paid public-health apprenticeships':
      'Lumikha ng bayad na public-health apprenticeships',
  'Replace the highest-risk water lines':
      'Palitan ang mga linyang-tubig na may pinakamataas na panganib',
  'Forward Bayhaven Party': 'Partidong Abante Bayhaven',
  'Business-backed executive': 'Ehekutibong suportado ng negosyo',
  'Put Bayhaven back to work.': 'Ibalik sa trabaho ang Bayhaven.',
  'A logistics executive and former development-board chair known for finishing projects quickly. His jobs agenda is detailed, while his record includes opaque subcontracting and little climate planning.':
      'Isang logistics executive at dating development-board chair na kilala sa mabilis na pagtatapos ng proyekto. Detalyado ang kaniyang jobs agenda, ngunit may malabong subcontracting at kaunting climate planning sa kaniyang rekord.',
  'Detailed employment program': 'Detalyadong programang pangtrabaho',
  'Strong project delivery record':
      'Malakas na rekord sa paghahatid ng proyekto',
  'Limited climate and health experience':
      'Limitadong karanasan sa klima at kalusugan',
  'Procurement transparency questions':
      'Mga tanong sa transparency ng procurement',
  'Offer incentives for local manufacturing':
      'Magbigay ng insentibo sa lokal na manufacturing',
  'Fast-track a logistics and market district':
      'Pabilisin ang logistics at market district',
  'Use private operators for water upgrades':
      'Gumamit ng pribadong operator sa water upgrades',
  'Common Ground Movement': 'Kilusang Common Ground',
  'Quiet administrator': 'Tahimik na administrador',
  'Repair the systems. Restore the trust.':
      'Ayusin ang sistema. Ibalik ang tiwala.',
  'A civil engineer and former water authority planner with a reputation for careful audits. His plans are technically grounded, though he has little electoral experience and a small council bloc.':
      'Isang civil engineer at dating water authority planner na kilala sa maingat na audit. Matibay sa teknikal ang kaniyang mga plano, ngunit kaunti ang karanasan sa halalan at maliit ang bloke sa konseho.',
  'Strong water and infrastructure planning':
      'Malakas sa pagpaplano ng tubig at imprastraktura',
  'Consistent transparency record': 'Pare-parehong rekord ng transparency',
  'Limited coalition support': 'Limitadong suporta ng koalisyon',
  'Employment plan may take time to produce jobs':
      'Maaaring matagalan bago lumikha ng trabaho ang plano',
  'Map and replace contaminated water lines':
      'Imapa at palitan ang kontaminadong linya ng tubig',
  'Publish every infrastructure contract':
      'Ilathala ang bawat kontrata sa imprastraktura',
  'Train residents for long-term repair work':
      'Sanayin ang residente sa pangmatagalang pagkukumpuni',
  'Three promises for Bayhaven': 'Tatlong pangako para sa Bayhaven',
  'A city ready to move': 'Lungsod na handang umusad',
  'Performance record': 'Rekord ng pagganap',
  'Independent budget reading': 'Malayang pagsusuri ng badyet',
  'Trending claim': 'Kumakalat na pahayag',
  'Claim review': 'Pagsusuri ng pahayag',
  'Unresolved questions': 'Mga tanong na hindi pa nasasagot',
  'Mayoral debate response': 'Sagot sa debate ng alkalde',
  'Career, education, and public-service background.':
      'Karanasan sa trabaho, edukasyon, at serbisyo publiko.',
  'A verified overview assembled from fictional city records.':
      'Beripikadong buod mula sa kathang-isip na rekord ng lungsod.',
  'The campaign presents its priorities for the next term.':
      'Inilalahad ng kampanya ang mga prayoridad para sa susunod na termino.',
  'Promises describe intent. Funding and delivery still require independent scrutiny.':
      'Ipinapakita ng pangako ang layunin. Kailangan pa ring suriin ang pondo at pagpapatupad.',
  'A polished advertisement frames the candidate as the answer to Bayhaven\'s urgent problems.':
      'Ipinapakita ng makinis na patalastas ang kandidato bilang sagot sa mga agarang problema ng Bayhaven.',
  'The advertisement uses selected success stories and does not discuss tradeoffs.':
      'Pinipili ng patalastas ang magagandang kuwento at hindi tinatalakay ang mga kapalit.',
  'Forwarded claim about Maya Vargas':
      'Ipinasa-pasang pahayag tungkol kay Maya Vargas',
  'Forwarded claim about Julian Pratt':
      'Ipinasa-pasang pahayag tungkol kay Julian Pratt',
  'Forwarded claim about Victor Chen':
      'Ipinasa-pasang pahayag tungkol kay Victor Chen',
  'A clip spreading without context': 'Klip na kumakalat nang walang konteksto',
  'An unsigned post claims insiders already know what Maya Vargas will do in office.':
      'Sinasabi ng post na walang pangalan na alam na ng insiders ang gagawin ni Maya Vargas sa puwesto.',
  'An unsigned post claims insiders already know what Julian Pratt will do in office.':
      'Sinasabi ng post na walang pangalan na alam na ng insiders ang gagawin ni Julian Pratt sa puwesto.',
  'An unsigned post claims insiders already know what Victor Chen will do in office.':
      'Sinasabi ng post na walang pangalan na alam na ng insiders ang gagawin ni Victor Chen sa puwesto.',
  'The post names no source and supplies no document. Repetition and urgency do not make a claim verified.':
      'Walang pinangalanang source o dokumento ang post. Hindi nagiging beripikado ang pahayag dahil lamang sa pag-uulit at pagmamadali.',
  'A short edited clip makes Maya Vargas appear to promise an immediate solution to every major problem.':
      'Pinalalabas ng maikling edited clip na nangako si Maya Vargas ng agarang solusyon sa bawat malaking problema.',
  'A short edited clip makes Julian Pratt appear to promise an immediate solution to every major problem.':
      'Pinalalabas ng maikling edited clip na nangako si Julian Pratt ng agarang solusyon sa bawat malaking problema.',
  'A short edited clip makes Victor Chen appear to promise an immediate solution to every major problem.':
      'Pinalalabas ng maikling edited clip na nangako si Victor Chen ng agarang solusyon sa bawat malaking problema.',
  'The excerpt removes the question and most of the answer. Find a full record before assigning it weight.':
      'Inalis sa sipi ang tanong at karamihan ng sagot. Hanapin ang buong rekord bago ito bigyan ng bigat.',
  'Clinic wait times fell in two pilot districts, although the program used a one-time grant.':
      'Bumaba ang oras ng paghihintay sa dalawang pilot district, bagaman isang beses na grant ang ginamit ng programa.',
  'The first-year plan leaves a funding gap if projected business taxes arrive late.':
      'May kakulangan sa pondo sa unang taon kung mahuhuli ang inaasahang buwis mula sa negosyo.',
  'A viral post says Vargas personally built twelve clinics. Records show she coordinated two mobile units.':
      'Sinasabi ng viral post na personal na nagtayo si Vargas ng labindalawang klinika. Dalawang mobile unit ang kaniyang pinangasiwaan ayon sa rekord.',
  'Her access claims are broadly supported; the construction claim circulating online is misleading.':
      'Malawak na sinusuportahan ang kaniyang pahayag sa access; mapanlinlang ang construction claim na kumakalat online.',
  'A medical distributor supporting her campaign could bid on city contracts. No improper award is documented.':
      'Maaaring lumahok sa bidding ng lungsod ang medical distributor na sumusuporta sa kaniyang kampanya. Walang dokumentadong maling paggawad.',
  'Vargas prioritizes clinic staffing first and proposes phased water repairs, but gives few details on long-term maintenance.':
      'Inuuna ni Vargas ang staffing ng klinika at phased water repairs, ngunit kaunti ang detalye sa pangmatagalang maintenance.',
  'Pratt delivered two development projects on schedule; job retention after subsidies ended was mixed.':
      'Natapos ni Pratt sa oras ang dalawang development project; halo-halo ang job retention matapos ang subsidies.',
  'The proposal identifies revenue sources but shifts long-term maintenance risk to later budgets.':
      'May tinukoy na revenue sources ang panukala ngunit inililipat sa susunod na badyet ang panganib ng long-term maintenance.',
  'Supporters claim every Pratt project created permanent jobs. Labor filings show many positions were seasonal.':
      'Sinasabi ng supporters na permanenteng trabaho ang nilikha ng bawat proyekto ni Pratt. Maraming seasonal na posisyon ang nasa labor filings.',
  'Project completion claims are accurate, while the permanent-job total lacks context.':
      'Tumpak ang project-completion claims, ngunit kulang sa konteksto ang bilang ng permanenteng trabaho.',
  'A family-linked contractor received subcontracts under a board Pratt chaired. The selection notes were not published.':
      'Nakatanggap ng subcontract ang contractor na konektado sa pamilya sa ilalim ng board na pinamunuan ni Pratt. Hindi inilathala ang selection notes.',
  'Pratt promises immediate hiring incentives and private water repairs, but avoids a question about flood standards.':
      'Nangangako si Pratt ng agarang hiring incentives at pribadong water repairs, ngunit iniiwasan ang tanong tungkol sa flood standards.',
  'Independent audits found accurate project reporting, but two upgrades were delayed by council votes.':
      'Natuklasan ng independent audits na tumpak ang project reporting, ngunit naantala ng boto ng konseho ang dalawang upgrade.',
  'The plan is fully costed and reserves maintenance funds, with fewer resources for immediate job subsidies.':
      'Kumpleto ang costing at may nakalaang maintenance funds ang plano, ngunit mas kaunti ang pondo para sa agarang job subsidies.',
  'A post calls Chen the author of a failed dam design. He reviewed safety compliance but did not design the dam.':
      'Tinatawag ng isang post si Chen na gumawa ng pumalyang dam design. Sinuri niya ang safety compliance ngunit hindi niya dinisenyo ang dam.',
  'The dam allegation misstates his role. His water-loss reduction figures match authority records.':
      'Mali ang paglalarawan ng alegasyon sa kaniyang papel sa dam. Tugma sa authority records ang water-loss reduction figures niya.',
  'Critics cite slow project starts during his tenure; meeting records show repeated coalition delays.':
      'Binabanggit ng mga kritiko ang mabagal na pagsisimula ng proyekto; paulit-ulit na coalition delays ang nasa meeting records.',
  'Chen gives a detailed repair sequence and audit plan, but struggles to explain how he will secure council votes.':
      'Nagbigay si Chen ng detalyadong repair sequence at audit plan, ngunit hirap ipaliwanag kung paano makukuha ang boto ng konseho.',
  'Bayhaven Election Desk': 'Tanggapan ng Halalan ng Bayhaven',
  'Bayhaven Records Office': 'Tanggapan ng mga Rekord ng Bayhaven',
  'Bayhaven Fact Desk': 'Fact Desk ng Bayhaven',
  'Bayhaven Public Media': 'Pampublikong Media ng Bayhaven',
  'Bayhaven Community Feed': 'Community Feed ng Bayhaven',
  'Civic Ledger Institute': 'Civic Ledger Institute',
  'HarborTalk user post': 'Post ng HarborTalk user',
  'The Bayhaven Beacon': 'The Bayhaven Beacon',
  'CityLoop video repost': 'CityLoop video repost',
};
