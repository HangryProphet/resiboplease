import '../models/city_problem.dart';
import '../models/news_media.dart';
import '../models/tv_broadcast.dart';

/// Builds optional TV presentations from the same immutable news-event truth.
///
/// Selection and copy are deterministic. This engine does not create city
/// facts, alter an event, or advance simulation state.
class TvBroadcastEngine {
  const TvBroadcastEngine();

  TvBroadcastCatalog build(NewsCatalog news) {
    final ranked = [...news.events]
      ..sort((first, second) {
        final priority = _priority(second).compareTo(_priority(first));
        return priority != 0 ? priority : first.id.compareTo(second.id);
      });
    final selected = ranked.where(_eligible).take(3).toList(growable: false);
    final events = selected.length >= 2
        ? selected
        : ranked.take(3).toList(growable: false);
    return TvBroadcastCatalog(
      broadcasts: List.unmodifiable(
        events.map((event) => _broadcastFor(event, news)),
      ),
    );
  }

  bool _eligible(UnderlyingNewsEvent event) =>
      event.chronicleVisibility &&
      (event.publicImpact >= 55 || event.importance >= 55);

  int _priority(UnderlyingNewsEvent event) =>
      ((event.publicImpact * 3) + (event.importance * 2)) ~/ 5;

  TvBroadcast _broadcastFor(UnderlyingNewsEvent event, NewsCatalog news) {
    final title = _issueTitle(event);
    final category = _category(event.relatedIssueFamily);
    final visualKey = event.imageAssetKey;
    final pages = <TvDialoguePage>[
      TvDialoguePage(
        id: '${event.id}_tv_hook',
        speakerId: 'reporter_r8',
        emotion: TvReporterEmotion.neutral,
        visualAssetKey: visualKey,
        text: TvLocalizedText(
          english:
              'Good evening, Bayhaven. Our lead report concerns ${title.english}. This is the same city event recorded in the Chronicle and local coverage.',
          filipino:
              'Magandang gabi, Bayhaven. Ang pangunahing ulat natin ay tungkol sa ${title.filipino}. Ito rin ang pangyayaring nakatala sa Kronika at mga lokal na ulat.',
        ),
      ),
      TvDialoguePage(
        id: '${event.id}_tv_record',
        speakerId: 'reporter_r8',
        emotion: TvReporterEmotion.concerned,
        visualAssetKey: visualKey,
        text: TvLocalizedText(
          english:
              'The shared public record places impact at ${event.publicImpact} out of 100 and civic importance at ${event.importance} out of 100. Those readings do not change between outlets.',
          filipino:
              'Nasa ${event.publicImpact} sa 100 ang epekto at ${event.importance} sa 100 ang kahalagahang sibiko sa iisang pampublikong tala. Hindi nagbabago ang mga bilang na iyon sa bawat outlet.',
        ),
      ),
      TvDialoguePage(
        id: '${event.id}_tv_impact',
        speakerId: 'reporter_r8',
        emotion: TvReporterEmotion.concerned,
        visualAssetKey: visualKey,
        text: _impactText(event.relatedIssueFamily),
      ),
      TvDialoguePage(
        id: '${event.id}_tv_response',
        speakerId: 'reporter_r8',
        emotion: TvReporterEmotion.emphatic,
        visualAssetKey: visualKey,
        text: event.relatedCandidateIds.isEmpty
            ? const TvLocalizedText(
                english:
                    'City officials still face choices about funding, timing, and institutional capacity. A proposal is not the same as a completed result.',
                filipino:
                    'May mga pagpili pa ang mga opisyal tungkol sa pondo, tiyempo, at kakayahan ng mga institusyon. Hindi pa natapos na resulta ang isang panukala.',
              )
            : const TvLocalizedText(
                english:
                    'Campaign promises connected to this issue are part of the public debate. A promise is not completed implementation, so records and funding still matter.',
                filipino:
                    'Bahagi ng pampublikong usapan ang mga pangakong konektado sa isyung ito. Hindi pa pagpapatupad ang pangako, kaya mahalaga pa rin ang mga rekord at pondo.',
              ),
      ),
      TvDialoguePage(
        id: '${event.id}_tv_signoff',
        speakerId: 'reporter_r8',
        emotion: TvReporterEmotion.signOff,
        visualAssetKey: visualKey,
        text: const TvLocalizedText(
          english:
              'What happens next remains unresolved. Compare the Chronicle, full articles, and related records before deciding what deserves your trust. R-8, City 8 News.',
          filipino:
              'Hindi pa tiyak ang susunod na mangyayari. Ihambing ang Kronika, buong artikulo, at kaugnay na rekord bago magpasya kung ano ang pagkakatiwalaan. R-8, City 8 News.',
        ),
      ),
    ];
    return TvBroadcast(
      id: 'tv_${event.id}',
      underlyingEventId: event.id,
      channelId: 'city_8_news',
      headline: title,
      category: category,
      broadcastType: event.publicImpact >= 70
          ? TvBroadcastType.breakingNews
          : TvBroadcastType.specialReport,
      reporterId: 'reporter_r8',
      visualAssetKey: visualKey,
      dialoguePages: List.unmodifiable(pages),
      relatedArticleIds: List.unmodifiable(
        news.coverageForEvent(event.id).map((coverage) => coverage.id),
      ),
      relatedCandidateIds: event.relatedCandidateIds,
      relatedIssueIds: [?event.relatedProblemId],
      date: event.fictionalDate,
      priority: _priority(event),
    );
  }
}

TvLocalizedText _issueTitle(UnderlyingNewsEvent event) {
  final family = event.relatedIssueFamily;
  return TvLocalizedText(
    english: event.title,
    filipino: switch (family) {
      CityIssueFamily.floodingDrainage => 'pagbaha at drainage',
      CityIssueFamily.corruptionPublicFunds => 'pondo ng bayan at procurement',
      CityIssueFamily.unfinishedRoads => 'mga hindi natapos na kalsada',
      CityIssueFamily.drugsCommunitySafety => 'kaligtasan ng komunidad',
      CityIssueFamily.garbageCleanliness => 'basura at kalinisan',
      CityIssueFamily.trafficTransport => 'trapiko at transportasyon',
      CityIssueFamily.waterSupply => 'suplay at kaligtasan ng tubig',
      CityIssueFamily.healthcareCapacity =>
        'kapasidad ng serbisyong pangkalusugan',
      CityIssueFamily.employmentQuality => 'kalidad ng trabaho',
      CityIssueFamily.costOfLiving => 'gastos ng pamumuhay',
      CityIssueFamily.governmentServices => 'serbisyo ng pamahalaan',
      CityIssueFamily.educationCapacity => 'kapasidad ng mga paaralan',
      null => event.title,
    },
  );
}

TvLocalizedText _category(CityIssueFamily? family) => switch (family) {
  CityIssueFamily.corruptionPublicFunds ||
  CityIssueFamily.governmentServices => const TvLocalizedText(
    english: 'Government Watch',
    filipino: 'Bantay Pamahalaan',
  ),
  CityIssueFamily.healthcareCapacity ||
  CityIssueFamily.drugsCommunitySafety => const TvLocalizedText(
    english: 'Health & Safety',
    filipino: 'Kalusugan at Kaligtasan',
  ),
  CityIssueFamily.employmentQuality || CityIssueFamily.costOfLiving =>
    const TvLocalizedText(english: 'Economy', filipino: 'Ekonomiya'),
  CityIssueFamily.floodingDrainage ||
  CityIssueFamily.waterSupply ||
  CityIssueFamily.garbageCleanliness => const TvLocalizedText(
    english: 'Environment Desk',
    filipino: 'Ulat Pangkapaligiran',
  ),
  CityIssueFamily.trafficTransport ||
  CityIssueFamily.unfinishedRoads => const TvLocalizedText(
    english: 'Infrastructure',
    filipino: 'Imprastraktura',
  ),
  CityIssueFamily.educationCapacity => const TvLocalizedText(
    english: 'Education',
    filipino: 'Edukasyon',
  ),
  null => const TvLocalizedText(
    english: 'Community Desk',
    filipino: 'Ulat Pangkomunidad',
  ),
};

TvLocalizedText _impactText(CityIssueFamily? family) => switch (family) {
  CityIssueFamily.floodingDrainage ||
  CityIssueFamily.waterSupply ||
  CityIssueFamily.garbageCleanliness => const TvLocalizedText(
    english:
        'For residents, this is a daily service and safety concern, not merely a number on a city dashboard. Conditions can affect homes, health, and access to essential systems.',
    filipino:
        'Para sa mga residente, usapin ito ng araw-araw na serbisyo at kaligtasan, hindi lang bilang sa city dashboard. Maaaring maapektuhan ang tahanan, kalusugan, at mahahalagang sistema.',
  ),
  CityIssueFamily.healthcareCapacity ||
  CityIssueFamily.drugsCommunitySafety => const TvLocalizedText(
    english:
        'The human impact appears in waiting time, access, and neighborhood safety. Immediate relief and durable capacity are related, but they are not identical choices.',
    filipino:
        'Makikita ang epekto sa oras ng paghihintay, access, at kaligtasan ng komunidad. Magkaugnay ang agarang tulong at pangmatagalang kapasidad, ngunit hindi sila iisang pagpili.',
  ),
  CityIssueFamily.employmentQuality ||
  CityIssueFamily.costOfLiving => const TvLocalizedText(
    english:
        'Households experience the issue through wages, prices, and the stability of everyday work. A headline about growth does not by itself show who benefits.',
    filipino:
        'Nararanasan ito ng mga pamilya sa sahod, presyo, at katatagan ng pang-araw-araw na trabaho. Hindi awtomatikong ipinapakita ng headline tungkol sa paglago kung sino ang nakikinabang.',
  ),
  CityIssueFamily.trafficTransport ||
  CityIssueFamily.unfinishedRoads => const TvLocalizedText(
    english:
        'Commuters and nearby businesses absorb delays through travel time, disrupted access, and uncertain project schedules. Completion claims still need a record.',
    filipino:
        'Sinasalo ng commuters at kalapit na negosyo ang dagdag na biyahe, sagabal sa access, at hindi tiyak na iskedyul. Kailangan pa rin ng rekord ang mga pahayag tungkol sa pagkumpleto.',
  ),
  CityIssueFamily.corruptionPublicFunds ||
  CityIssueFamily.governmentServices => const TvLocalizedText(
    english:
        'Residents feel the issue through delayed services and questions about how public resources are used. Suspicion is not proof, but public records still deserve scrutiny.',
    filipino:
        'Nararanasan ito sa mabagal na serbisyo at mga tanong sa paggamit ng pampublikong yaman. Hindi patunay ang hinala, ngunit dapat pa ring suriin ang mga pampublikong rekord.',
  ),
  CityIssueFamily.educationCapacity => const TvLocalizedText(
    english:
        'Students and teachers experience capacity pressure through crowded rooms, limited materials, and difficult staffing choices. Enrollment alone does not measure learning quality.',
    filipino:
        'Nararanasan ng mag-aaral at guro ang pressure sa siksikang silid, limitadong kagamitan, at mahihirap na staffing choice. Hindi sapat ang enrollment para sukatin ang kalidad ng pagkatuto.',
  ),
  null => const TvLocalizedText(
    english:
        'Residents experience the event beyond a headline. The shared record separates what is known from what still needs confirmation.',
    filipino:
        'Nararanasan ng mga residente ang pangyayari lampas sa headline. Pinaghihiwalay ng iisang tala ang alam na sa kailangan pang kumpirmahin.',
  ),
};
