import 'package:flutter/widgets.dart';

import '../domain/models/tv_broadcast.dart';

extension TvBroadcastLocalization on BuildContext {
  TvBroadcastStrings get tvStrings =>
      TvBroadcastStrings(Localizations.localeOf(this).languageCode);
}

class TvBroadcastStrings {
  const TvBroadcastStrings(this.languageCode);

  final String languageCode;

  bool get _filipino => languageCode == 'fil';

  String get channelName => 'CITY 8 NEWS';
  String get reporterName => 'R-8';
  String get reporterTitle =>
      _filipino ? 'Robotic na tagapagbalita' : 'Robotic news anchor';
  String get watchReport => _filipino ? 'Panoorin ang Ulat' : 'Watch Report';
  String get watchTvReport =>
      _filipino ? 'Panoorin ang TV Report' : 'Watch TV Report';
  String get dialogueSounds =>
      _filipino ? 'Tunog ng Dialogue' : 'Dialogue Sounds';
  String get dialogueSoundsDescription => _filipino
      ? 'Magpatugtog ng maikling electronic chirp habang lumalabas ang dialogue.'
      : 'Play a short electronic chirp while dialogue is being revealed.';
  String get live => 'LIVE';
  String get tapToComplete => _filipino
      ? 'I-tap para kumpletuhin ang kasalukuyang linya'
      : 'Tap to complete the current line';
  String get tapForNext => _filipino ? 'I-tap para sa susunod' : 'Tap for next';
  String get tapToFinish =>
      _filipino ? 'I-tap para tapusin ang ulat' : 'Tap to finish report';
  String get broadcastComplete =>
      _filipino ? 'Tapos na ang Broadcast' : 'Broadcast Complete';
  String get backToChronicle =>
      _filipino ? 'Bumalik sa Kronika' : 'Back to Chronicle';
  String get readFullArticle =>
      _filipino ? 'Basahin ang Buong Artikulo' : 'Read Full Article';
  String get sharedEventNotice => _filipino
      ? 'Presentasyon ito ng parehong pangyayaring nasa Kronika at News.'
      : 'This presents the same event used by Chronicle and News.';
  String get reportUnavailable =>
      _filipino ? 'Hindi available ang ulat na ito.' : 'Report unavailable.';

  String pageProgress(int current, int total) =>
      _filipino ? 'Pahina $current sa $total' : 'Page $current of $total';

  String broadcastType(TvBroadcastType type) => switch (type) {
    TvBroadcastType.breakingNews =>
      _filipino ? 'NAGBABAGANG BALITA' : 'BREAKING NEWS',
    TvBroadcastType.specialReport =>
      _filipino ? 'ESPESYAL NA ULAT' : 'SPECIAL REPORT',
    TvBroadcastType.communityFeature =>
      _filipino ? 'ULAT PANGKOMUNIDAD' : 'COMMUNITY FEATURE',
  };
}
