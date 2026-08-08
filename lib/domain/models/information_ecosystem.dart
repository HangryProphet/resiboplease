import 'citybook.dart';
import 'information_reference.dart';
import 'news_media.dart';
import 'tv_broadcast.dart';

class InformationEcosystem {
  const InformationEcosystem({
    required this.cityBook,
    required this.news,
    required this.tvBroadcasts,
    required this.relationships,
  });

  final CityBookCatalog cityBook;
  final NewsCatalog news;
  final TvBroadcastCatalog tvBroadcasts;
  final List<InformationRelationship> relationships;

  Iterable<InformationRelationship> relationshipsFrom(
    InformationArtifactKind kind,
    String id,
  ) => relationships.where(
    (relation) => relation.from.kind == kind && relation.from.id == id,
  );
}
