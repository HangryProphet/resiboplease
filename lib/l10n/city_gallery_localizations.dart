import 'package:flutter/widgets.dart';

extension CityGalleryBuildContext on BuildContext {
  CityGalleryStrings get galleryStrings =>
      Localizations.localeOf(this).languageCode == 'fil'
      ? const CityGalleryStrings.filipino()
      : const CityGalleryStrings.english();
}

class CityGalleryStrings {
  const CityGalleryStrings.english() : filipino = false;
  const CityGalleryStrings.filipino() : filipino = true;

  final bool filipino;

  String get visitCities =>
      filipino ? 'Bisitahin ang mga Lungsod' : 'Visit Cities';
  String get title => filipino ? 'Mga Pampublikong Lungsod' : 'Public Cities';
  String get subtitle => filipino
      ? 'Ligtas at kathang-isip na mga resulta'
      : 'Sanitized fictional results';
  String get loading => filipino
      ? 'Kinukuha ang pinakabagong mga lungsod...'
      : 'Retrieving the newest cities...';
  String get empty => filipino
      ? 'Wala pang nailalathalang lungsod.'
      : 'No cities have been published yet.';
  String get emptyBody => filipino
      ? 'Tapusin ang isang termino at ilathala ang ligtas na snapshot nito.'
      : 'Complete a term and publish its sanitized snapshot.';
  String get retry => filipino ? 'Subukan Muli' : 'Retry';
  String get offline => filipino
      ? 'Offline — ipinapakita ang naka-save na mga resulta.'
      : 'Offline — showing saved results.';
  String get cachedServer => filipino
      ? 'Hindi maabot ang live gallery — ipinapakita ang naka-save na resulta.'
      : 'Live gallery unavailable — showing saved results.';
  String get unavailable => filipino
      ? 'Hindi maabot ang city gallery ngayon.'
      : 'The city gallery cannot be reached right now.';
  String get invalidResponse => filipino
      ? 'Hindi mabasa ang tugon ng gallery.'
      : 'The gallery returned data that could not be read.';
  String get notConfigured => filipino
      ? 'Hindi pa nakakonekta ang city gallery.'
      : 'The city gallery has not been connected yet.';
  String get term => filipino ? 'Termino' : 'Term';
  String get electedLeader => filipino ? 'Nahalal na pinuno' : 'Elected leader';
  String get topIssue => filipino ? 'Pangunahing isyu' : 'Top issue';
  String get finalCondition =>
      filipino ? 'Huling kalagayan' : 'Final condition';
  String get startingCondition =>
      filipino ? 'Panimulang kalagayan' : 'Starting condition';
  String get party => filipino ? 'Partido' : 'Party';
  String get majorIssues => filipino ? 'Malalaking isyu' : 'Major issues';
  String get majorEvents =>
      filipino ? 'Mahahalagang pangyayari' : 'Major events';
  String get published => filipino ? 'Nailathala' : 'Published';
  String get viewDetails => filipino ? 'Tingnan ang Detalye' : 'View Details';
  String get citySnapshot => filipino ? 'Snapshot ng Lungsod' : 'City Snapshot';
  String get publishAction =>
      filipino ? 'Ilathala ang Snapshot ng Lungsod' : 'Publish City Snapshot';
  String get publishing => filipino ? 'Inilalathala...' : 'Publishing...';
  String get publishSuccess => filipino ? 'Nailathala' : 'Published';
  String get publishFailure =>
      filipino ? 'Nabigo — Subukan Muli' : 'Failed — Retry';
  String get publishTitle => filipino
      ? 'Ilathala ang kathang-isip na resulta?'
      : 'Publish fictional city result?';
  String get publishExplanation => filipino
      ? 'Tanging pangalan at ligtas na buod ng kathang-isip na lungsod, termino, kandidato, isyu, at mga pangyayari ang ibabahagi. Hindi kasama ang save file, world seed, hidden stats, o investigation history.'
      : 'Only a sanitized fictional summary of the city, term, candidate, issues, and events will be shared. The save file, world seed, hidden stats, and investigation history are never included.';
  String get confirmPublish => filipino ? 'Ilathala' : 'Publish';
  String get cancel => filipino ? 'Kanselahin' : 'Cancel';
  String get publicSharingNote => filipino
      ? 'Pampublikong API: kathang-isip na resulta lamang'
      : 'Public API: fictional results only';
}
