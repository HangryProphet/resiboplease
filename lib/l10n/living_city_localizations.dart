import 'package:flutter/widgets.dart';

import '../core/settings/app_settings_controller.dart';
import '../domain/models/living_city_simulation.dart';

extension LivingCityLocalizations on BuildContext {
  bool get _livingCityFilipino =>
      Localizations.localeOf(this).languageCode == 'fil';

  String get citySimulation =>
      _livingCityFilipino ? 'Buhay na Lungsod' : 'Living City';
  String get eventHistory =>
      _livingCityFilipino ? 'Kasaysayan' : 'Event History';
  String get mayorOffice =>
      _livingCityFilipino ? 'Tanggapan ng Mayor' : 'Mayor\'s Office';
  String get administration =>
      _livingCityFilipino ? 'Administrasyon' : 'Administration';
  String get projects => _livingCityFilipino ? 'Mga Proyekto' : 'Projects';
  String get currentMayor =>
      _livingCityFilipino ? 'Kasalukuyang Mayor' : 'Current Mayor';
  String get publicTrust =>
      _livingCityFilipino ? 'Tiwala ng Publiko' : 'Public Trust';
  String get budgetHealth =>
      _livingCityFilipino ? 'Kalagayan ng Badyet' : 'Budget Health';
  String get cityCondition =>
      _livingCityFilipino ? 'Kalagayan ng Lungsod' : 'City Condition';
  String get pause => _livingCityFilipino ? 'Hinto' : 'Pause';
  String get daySpeed => _livingCityFilipino ? 'Araw' : 'Day';
  String get weekSpeed => _livingCityFilipino ? 'Linggo' : 'Week';
  String get monthSpeed => _livingCityFilipino ? 'Buwan' : 'Month';
  String get yearSpeed => _livingCityFilipino ? 'Taon' : 'Year';
  String get paused => _livingCityFilipino ? 'Nakahinto' : 'Paused';
  String get running => _livingCityFilipino ? 'Tumatakbo' : 'Running';
  String get currentCondition =>
      _livingCityFilipino ? 'KASALUKUYANG KONDISYON' : 'CURRENT CONDITION';
  String get noExternalPressure => _livingCityFilipino
      ? 'Maaliwalas · Walang malaking panlabas na presyon'
      : 'Clear · No major external pressure';
  String get latestDevelopment =>
      _livingCityFilipino ? 'Pinakabagong Pangyayari' : 'Latest Development';
  String get noEventsYet => _livingCityFilipino
      ? 'Tahimik pa ang lungsod. Patakbuhin ang oras.'
      : 'The city is quiet so far. Let time run.';
  String get allEvents => _livingCityFilipino ? 'Lahat' : 'All';
  String get majorEvents => _livingCityFilipino ? 'Mahalaga' : 'Major';
  String get projectEvents => _livingCityFilipino ? 'Proyekto' : 'Projects';
  String get communityEvents => _livingCityFilipino ? 'Komunidad' : 'Community';
  String get viewStory =>
      _livingCityFilipino ? 'Tingnan ang Kuwento' : 'View Story';
  String get readNews =>
      _livingCityFilipino ? 'Basahin ang Balita' : 'Read News';
  String get watchReport =>
      _livingCityFilipino ? 'Panoorin ang Ulat' : 'Watch Report';
  String get openChronicle =>
      _livingCityFilipino ? 'Buksan ang Chronicle' : 'Open Chronicle';
  String get viewProject =>
      _livingCityFilipino ? 'Tingnan ang Proyekto' : 'View Project';
  String get yearComplete =>
      _livingCityFilipino ? 'Tapos na ang Taon' : 'Year Complete';
  String get openTermReport =>
      _livingCityFilipino ? 'Buksan ang Ulat ng Termino' : 'Open Term Report';
  String get criticalInterruption => _livingCityFilipino
      ? 'Pag-abala ng Kritikal na Pangyayari'
      : 'Critical Event Interruption';
  String get criticalInterruptionDescription => _livingCityFilipino
      ? 'Piliin kung paano ka aabalahin ng kritikal at bihirang pangyayari.'
      : 'Choose how critical and rare developments get your attention.';
  String get markerHint => _livingCityFilipino
      ? 'I-drag at i-zoom ang mapa. Pindutin ang marker para siyasatin.'
      : 'Drag and zoom the map. Tap a marker to inspect it.';
  String get cityLandmark =>
      _livingCityFilipino ? 'Palatandaan ng Lungsod' : 'City Landmark';
  String get recentDevelopments => _livingCityFilipino
      ? 'Mga Kamakailang Pangyayari'
      : 'Recent Developments';
  String get noDevelopmentsAtLocation => _livingCityFilipino
      ? 'Wala pang naitalang pangyayari sa lugar na ito.'
      : 'No developments have been recorded here yet.';
  String get zoomIn => _livingCityFilipino ? 'Palakihin ang mapa' : 'Zoom in';
  String get zoomOut => _livingCityFilipino ? 'Paliitin ang mapa' : 'Zoom out';
  String get resetMap =>
      _livingCityFilipino ? 'Ibalik ang buong mapa' : 'Reset map view';

  String mapLocationLabel(CityMapAnchor anchor) => switch (anchor.id) {
    'city_hall' => mayorOffice,
    'civic_center' => _livingCityFilipino ? 'Sentrong Sibiko' : 'Civic Center',
    'central_avenue' =>
      _livingCityFilipino ? 'Pangunahing Abenida' : 'Central Avenue',
    'city_plaza' => _livingCityFilipino ? 'Liwasang Bayan' : 'City Plaza',
    'government_services_center' =>
      _livingCityFilipino
          ? 'Sentro ng Serbisyo ng Lungsod'
          : 'Government Services Center',
    'news_headquarters' =>
      _livingCityFilipino ? 'Himpilan ng Balita' : 'News Headquarters',
    'riverside' => _livingCityFilipino ? 'Tabing-Ilog' : 'Riverside',
    'riverside_community' =>
      _livingCityFilipino ? 'Pamayanang Tabing-Ilog' : 'Riverside Community',
    'water_facility' =>
      _livingCityFilipino ? 'Pasilidad ng Tubig' : 'Water Facility',
    'west_residential' =>
      _livingCityFilipino ? 'Kanlurang Kabahayan' : 'West Residential',
    'north_residential' =>
      _livingCityFilipino ? 'Hilagang Kabahayan' : 'North Residential',
    'university' =>
      _livingCityFilipino ? 'Pamantasan ng Bayhaven' : 'Bayhaven University',
    'subdivision_area' =>
      _livingCityFilipino ? 'Nakasarang Subdibisyon' : 'Gated Subdivision',
    'hospital' =>
      _livingCityFilipino ? 'Pampublikong Ospital' : 'Public Hospital',
    'school_district' =>
      _livingCityFilipino ? 'Distrito ng mga Paaralan' : 'School District',
    'east_residential' =>
      _livingCityFilipino ? 'Silangang Kabahayan' : 'East Residential',
    'police_hq' =>
      _livingCityFilipino ? 'Punong Himpilan ng Pulis' : 'Police Headquarters',
    'public_market' =>
      _livingCityFilipino ? 'Pampublikong Palengke' : 'Public Market',
    'commercial_center' =>
      _livingCityFilipino ? 'Sentrong Komersyal' : 'Commercial Center',
    'shopping_mall' =>
      _livingCityFilipino ? 'Pamilihan ng Bayhaven' : 'Bayhaven Mall',
    'waste_segregation_center' =>
      _livingCityFilipino
          ? 'Sentro ng Paghihiwalay ng Basura'
          : 'Waste Segregation Center',
    'transport_terminal' =>
      _livingCityFilipino ? 'Terminal ng Transportasyon' : 'Transport Terminal',
    'warehouse_logistics' =>
      _livingCityFilipino ? 'Bodega at Logistics' : 'Warehouse & Logistics',
    'south_residential' =>
      _livingCityFilipino ? 'Timog na Kabahayan' : 'South Residential',
    'fire_disaster_center' =>
      _livingCityFilipino
          ? 'Sentro ng Sunog at Sakuna'
          : 'Fire & Disaster Center',
    'community_sports_area' =>
      _livingCityFilipino ? 'Sentrong Pampalakasan' : 'Community Sports Center',
    'industrial_zone' =>
      _livingCityFilipino ? 'Sonang Industriyal' : 'Industrial Zone',
    _ => anchor.label,
  };

  String mapLocationShortLabel(CityMapAnchor anchor) => switch (anchor.id) {
    'city_hall' => _livingCityFilipino ? 'MAYOR' : 'MAYOR',
    'hospital' => _livingCityFilipino ? 'OSPITAL' : 'HOSPITAL',
    'school_district' => _livingCityFilipino ? 'PAARALAN' : 'SCHOOLS',
    'public_market' => _livingCityFilipino ? 'PALENGKE' : 'MARKET',
    'transport_terminal' => 'TERMINAL',
    'news_headquarters' => _livingCityFilipino ? 'BALITA' : 'NEWS HQ',
    'waste_segregation_center' => 'MRF / WASTE',
    'subdivision_area' => _livingCityFilipino ? 'SUBDIBISYON' : 'SUBDIVISION',
    'shopping_mall' => 'CITY MALL',
    'police_hq' => _livingCityFilipino ? 'PULIS' : 'POLICE HQ',
    'fire_disaster_center' => _livingCityFilipino ? 'BOMBERO' : 'FIRE & RESCUE',
    'water_facility' => _livingCityFilipino ? 'TUBIG' : 'WATER WORKS',
    'government_services_center' =>
      _livingCityFilipino ? 'SERBISYO' : 'CITY SERVICES',
    'city_plaza' => _livingCityFilipino ? 'LIWASAN' : 'CITY PLAZA',
    'riverside_community' => 'RIVERSIDE',
    'industrial_zone' => _livingCityFilipino ? 'INDUSTRIYA' : 'INDUSTRIAL',
    'university' => _livingCityFilipino ? 'PAMANTASAN' : 'UNIVERSITY',
    'warehouse_logistics' => 'LOGISTICS',
    'community_sports_area' => _livingCityFilipino ? 'PALAKASAN' : 'SPORTS',
    _ => mapLocationLabel(anchor),
  };

  String landmarkDescription(CityMapAnchor anchor) => switch (anchor.id) {
    'hospital' =>
      _livingCityFilipino
          ? 'Pangunahing sentro ng serbisyong pangkalusugan at tugon sa emerhensiya.'
          : 'The city\'s main public-health and emergency-response complex.',
    'public_market' =>
      _livingCityFilipino
          ? 'Sentro ng presyo ng pagkain, maliliit na negosyo, at kabuhayan.'
          : 'A hub for food prices, small businesses, and daily livelihoods.',
    'school_district' =>
      _livingCityFilipino
          ? 'Kumpol ng mga pampublikong paaralan at pasilidad para sa kabataan.'
          : 'A cluster of public schools and youth facilities.',
    'transport_terminal' =>
      _livingCityFilipino
          ? 'Pangunahing hintuan ng bus at jeep na nag-uugnay sa mga distrito.'
          : 'The bus and jeep hub connecting Bayhaven\'s districts.',
    'news_headquarters' =>
      _livingCityFilipino
          ? 'Punong himpilan ng mga lokal na ulat at pampublikong impormasyon.'
          : 'The main hub for local reporting and public-information coverage.',
    'waste_segregation_center' =>
      _livingCityFilipino
          ? 'Pasilidad para sa paghihiwalay, pagbawi, at pagproseso ng basura.'
          : 'The city facility for waste sorting, recovery, and processing.',
    'police_hq' =>
      _livingCityFilipino
          ? 'Sentro ng koordinasyon para sa kaligtasan at tugon ng pulisya.'
          : 'The coordination center for public safety and police response.',
    'fire_disaster_center' =>
      _livingCityFilipino
          ? 'Himpilan ng bumbero at tugon sa sakuna ng lungsod.'
          : 'The city base for fire, rescue, and disaster response.',
    'water_facility' =>
      _livingCityFilipino
          ? 'Pasilidad na nagpoproseso at nagpapadaloy ng suplay ng tubig.'
          : 'The facility that treats and pumps the city water supply.',
    _ =>
      _livingCityFilipino
          ? 'Isang mahalagang lugar sa buhay ng lungsod.'
          : 'An important location in the life of the city.',
  };

  String speedLabel(SimulationSpeed speed) => switch (speed) {
    SimulationSpeed.day => daySpeed,
    SimulationSpeed.week => weekSpeed,
    SimulationSpeed.month => monthSpeed,
    SimulationSpeed.year => yearSpeed,
  };

  String worldConditionLabel(WorldConditionType type) => switch (type) {
    WorldConditionType.sunnyStretch =>
      _livingCityFilipino ? 'Sunod-sunod na Maaraw' : 'Sunny Stretch',
    WorldConditionType.heavyRain =>
      _livingCityFilipino ? 'Malakas na Ulan' : 'Heavy Rain',
    WorldConditionType.severeThunderstorms =>
      _livingCityFilipino ? 'Matinding Pagkidlat' : 'Severe Thunderstorms',
    WorldConditionType.heatWave =>
      _livingCityFilipino ? 'Matinding Init' : 'Heat Wave',
    WorldConditionType.strongTyphoon =>
      _livingCityFilipino ? 'Malakas na Bagyo' : 'Strong Typhoon',
    WorldConditionType.monsoonPeriod =>
      _livingCityFilipino ? 'Panahon ng Habagat' : 'Monsoon Period',
    WorldConditionType.oilPriceCrisis =>
      _livingCityFilipino ? 'Krisis sa Presyo ng Langis' : 'Oil Price Crisis',
    WorldConditionType.fuelPriceDrop =>
      _livingCityFilipino ? 'Bumabang Presyo ng Gasolina' : 'Fuel Price Drop',
    WorldConditionType.supplyShortage =>
      _livingCityFilipino ? 'Kakulangan sa Suplay' : 'Supply Shortage',
    WorldConditionType.regionalEconomicSlowdown =>
      _livingCityFilipino
          ? 'Pagbagal ng Rehiyonal na Ekonomiya'
          : 'Regional Economic Slowdown',
    WorldConditionType.businessExpansion =>
      _livingCityFilipino ? 'Paglawak ng mga Negosyo' : 'Business Expansion',
    WorldConditionType.constructionMaterialIncrease =>
      _livingCityFilipino
          ? 'Mahal na Materyales sa Konstruksyon'
          : 'Construction Material Price Increase',
    WorldConditionType.regionalPowerInstability =>
      _livingCityFilipino
          ? 'Hindi Matatag na Kuryente'
          : 'Regional Power Instability',
    WorldConditionType.waterSupplyPressure =>
      _livingCityFilipino
          ? 'Presyon sa Suplay ng Tubig'
          : 'Water-Supply Pressure',
    WorldConditionType.telecommunicationsOutage =>
      _livingCityFilipino
          ? 'Pagkaputol ng Telekomunikasyon'
          : 'Telecommunications Outage',
    WorldConditionType.logisticsDisruption =>
      _livingCityFilipino ? 'Problema sa Logistics' : 'Logistics Disruption',
    WorldConditionType.festivalWeek =>
      _livingCityFilipino ? 'Linggo ng Pista' : 'Festival Week',
    WorldConditionType.schoolOpening =>
      _livingCityFilipino ? 'Pagbubukas ng Paaralan' : 'School Opening Period',
    WorldConditionType.holidayRush =>
      _livingCityFilipino ? 'Bugso ng Kapaskuhan' : 'Holiday Rush',
    WorldConditionType.fluDengueSeason =>
      _livingCityFilipino
          ? 'Panahon ng Trangkaso at Dengue'
          : 'Flu/Dengue Season',
    WorldConditionType.graduationPeriod =>
      _livingCityFilipino ? 'Panahon ng Pagtatapos' : 'Exam/Graduation Period',
  };

  String conditionDaysRemaining(int days) => _livingCityFilipino
      ? '$days araw ang natitira'
      : '$days ${days == 1 ? 'day' : 'days'} remaining';

  String criticalInterruptionLabel(CriticalEventInterruption mode) =>
      switch (mode) {
        CriticalEventInterruption.autoOpen =>
          _livingCityFilipino ? 'Awtomatikong Buksan' : 'Auto Open',
        CriticalEventInterruption.pauseAndNotify =>
          _livingCityFilipino ? 'Huminto at Magbigay-Alam' : 'Pause & Notify',
        CriticalEventInterruption.notifyOnly =>
          _livingCityFilipino ? 'Magbigay-Alam Lamang' : 'Notify Only',
        CriticalEventInterruption.neverInterrupt =>
          _livingCityFilipino ? 'Huwag Mang-abala' : 'Never Interrupt',
      };

  String criticalInterruptionDetails(
    CriticalEventInterruption mode,
  ) => switch (mode) {
    CriticalEventInterruption.autoOpen =>
      _livingCityFilipino
          ? 'Hihinto ang oras at awtomatikong bubuksan ang tala.'
          : 'Pauses time and automatically opens the event record.',
    CriticalEventInterruption.pauseAndNotify =>
      _livingCityFilipino
          ? 'Hihinto ang oras at magpapakita ng abiso, pero ikaw ang magbubukas.'
          : 'Pauses and shows a notice; opening remains your choice.',
    CriticalEventInterruption.notifyOnly =>
      _livingCityFilipino
          ? 'Tuloy ang oras habang ipinapakita ang abiso at marker.'
          : 'Time continues while a notice and marker are shown.',
    CriticalEventInterruption.neverInterrupt =>
      _livingCityFilipino
          ? 'Walang awtomatikong abiso o paghinto; nasa kasaysayan pa rin.'
          : 'No automatic notice or pause; the event still enters history.',
  };

  String conditionLabel(OverallCityCondition condition) => switch (condition) {
    OverallCityCondition.thriving =>
      _livingCityFilipino ? 'Masigla' : 'Thriving',
    OverallCityCondition.improving =>
      _livingCityFilipino ? 'Gumaganda' : 'Improving',
    OverallCityCondition.stable => _livingCityFilipino ? 'Matatag' : 'Stable',
    OverallCityCondition.strained =>
      _livingCityFilipino ? 'Nahihirapan' : 'Strained',
    OverallCityCondition.deteriorating =>
      _livingCityFilipino ? 'Lumalalang' : 'Deteriorating',
    OverallCityCondition.crisis => _livingCityFilipino ? 'Krisis' : 'Crisis',
  };
}
