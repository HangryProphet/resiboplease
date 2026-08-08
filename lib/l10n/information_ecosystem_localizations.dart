import 'package:flutter/widgets.dart';

import '../domain/models/citybook.dart';
import '../domain/models/news_media.dart';

extension InformationEcosystemLocalization on BuildContext {
  InformationEcosystemStrings get informationStrings =>
      InformationEcosystemStrings(Localizations.localeOf(this).languageCode);
}

class InformationEcosystemStrings {
  const InformationEcosystemStrings(this.languageCode);
  final String languageCode;
  bool get isFilipino => languageCode == 'fil';

  String get cityBook => 'CityBook';
  String get posts => isFilipino ? 'Mga Post' : 'Posts';
  String get about => isFilipino ? 'Tungkol' : 'About';
  String get media => isFilipino ? 'Media' : 'Media';
  String get followers => isFilipino ? 'tagasubaybay' : 'followers';
  String get publicSentiment =>
      isFilipino ? 'Reaksyon ng publiko' : 'Public sentiment';
  String get comments => isFilipino ? 'Mga komento' : 'Comments';
  String get viewComments =>
      isFilipino ? 'Tingnan ang mga komento' : 'View comments';
  String get close => isFilipino ? 'Isara' : 'Close';
  String get historicalPost => isFilipino
      ? 'Lumang post na muling lumitaw'
      : 'Resurfaced historical post';
  String get viewContext =>
      isFilipino ? 'Tingnan ang konteksto' : 'View context';
  String get viewReceipt => isFilipino ? 'Tingnan ang resibo' : 'View receipt';
  String get investigateClaim =>
      isFilipino ? 'Suriin ang pahayag' : 'Investigate claim';
  String get readCoverage =>
      isFilipino ? 'Basahin ang mga ulat' : 'Read coverage';
  String get recentCoverage =>
      isFilipino ? 'Kamakailang Ulat' : 'Recent Coverage';
  String get compareCoverage =>
      isFilipino ? 'Ihambing ang mga Ulat' : 'Compare Coverage';
  String get sameEventNote => isFilipino
      ? 'Iisang pangyayari at talaan, magkakaibang diin at headline.'
      : 'One event and shared record, with different emphasis and headlines.';
  String get framingAngle => isFilipino ? 'Diin ng ulat' : 'Framing angle';
  String get fullStory => isFilipino ? 'Buong artikulo' : 'Full story';
  String get relatedStories =>
      isFilipino ? 'Kaugnay na mga Ulat' : 'Related Stories';
  String get relatedCandidate =>
      isFilipino ? 'Kaugnay na kandidato' : 'Related candidate';
  String get relatedCityIssue =>
      isFilipino ? 'Kaugnay na isyu ng lungsod' : 'Related city issue';
  String get relatedRecord =>
      isFilipino ? 'Kaugnay na rekord' : 'Related record';
  String get articleImagePending => isFilipino
      ? 'Nakalaang puwesto para sa larawan ng ulat'
      : 'Reserved article image placement';
  String get profileBannerPending =>
      isFilipino ? 'Nakalaang profile banner' : 'Reserved profile banner';
  String get postMediaPending =>
      isFilipino ? 'Nakalaang media ng post' : 'Reserved post media';
  String get outletPersonality =>
      isFilipino ? 'Estilo ng publikasyon' : 'Publication style';
  String get transparencyPortal => isFilipino
      ? 'Bayhaven Transparency Portal'
      : 'Bayhaven Transparency Portal';
  String get publicRecord =>
      isFilipino ? 'Pampublikong Rekord' : 'Public Record';
  String get recordId => isFilipino ? 'Record ID' : 'Record ID';
  String get issuingOffice => isFilipino ? 'Tanggapan' : 'Issuing office';
  String get recordStatus => isFilipino ? 'Katayuan' : 'Status';
  String get available =>
      isFilipino ? 'Bukas sa publiko' : 'Publicly available';
  String get normalizedReaderNote => isFilipino
      ? 'Ang presentasyong ito ay ayon sa source. Nasa ibaba pa rin ang kumpletong normalized Evidence Reader.'
      : 'This presentation follows the source type. The complete normalized Evidence Reader remains below.';

  String reactionLabel(CityBookReaction reaction) => switch (reaction) {
    CityBookReaction.like => 'Like',
    CityBookReaction.love => 'Love',
    CityBookReaction.laugh => 'Laugh',
    CityBookReaction.shock => 'Shock',
    CityBookReaction.sad => 'Sad',
    CityBookReaction.angry => 'Angry',
    CityBookReaction.receipt => 'Resibo?',
  };

  String postTypeLabel(CityBookPostType type) => switch (type) {
    CityBookPostType.text => isFilipino ? 'Pahayag' : 'Post',
    CityBookPostType.imageCaption => isFilipino ? 'Larawan' : 'Photo',
    CityBookPostType.campaignAnnouncement =>
      isFilipino ? 'Anunsyo' : 'Campaign announcement',
    CityBookPostType.policyStatement =>
      isFilipino ? 'Patakaran' : 'Policy statement',
    CityBookPostType.criticismResponse => isFilipino ? 'Tugon' : 'Response',
    CityBookPostType.accomplishmentClaim =>
      isFilipino ? 'Pahayag ng nagawa' : 'Accomplishment claim',
    CityBookPostType.eventAppearance =>
      isFilipino ? 'Kaganapan' : 'Event appearance',
    CityBookPostType.opponentAttack =>
      isFilipino ? 'Pagbatikos' : 'Opponent criticism',
    CityBookPostType.clarification =>
      isFilipino ? 'Paglilinaw' : 'Clarification',
    CityBookPostType.apology => isFilipino ? 'Paumanhin' : 'Apology',
    CityBookPostType.supportMessage =>
      isFilipino ? 'Pakikiisa' : 'Support message',
    CityBookPostType.historical =>
      isFilipino ? 'Lumang post' : 'Historical post',
    CityBookPostType.slogan => isFilipino ? 'Slogan' : 'Campaign slogan',
    CityBookPostType.publicServiceAnnouncement => 'Public-service announcement',
  };

  String formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }

  String outletTraits(NewsOutlet outlet) => [
    outlet.depth.name,
    outlet.speed.name,
    outlet.tone.name,
    outlet.headlineStyle.name,
  ].join(' · ');
}
