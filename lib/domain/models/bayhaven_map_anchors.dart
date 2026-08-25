/// Stable simulation districts used by event templates and map anchors.
enum CitySimulationDistrict {
  civicCenter,
  riverside,
  oldMarket,
  northWard,
  southPoint,
  harborDistrict,
  hillview,
  industrialBelt,
}

enum CityMapAnchorType {
  civic,
  health,
  education,
  market,
  transport,
  media,
  sanitation,
  residential,
  commercial,
  publicSafety,
  emergency,
  utility,
  park,
  industrial,
  logistics,
  road,
  recreation,
}

/// A normalized logical point on the square Bayhaven map.
class CityMapAnchor {
  const CityMapAnchor({
    required this.id,
    required this.labelKey,
    required this.label,
    required this.type,
    required this.district,
    required this.x,
    required this.y,
    this.landmark = false,
  });

  final String id;
  final String labelKey;
  final String label;
  final CityMapAnchorType type;
  final CitySimulationDistrict district;
  final double x;
  final double y;
  final bool landmark;
}

/// The single source of truth for visible geography on
/// `bayhaven_topdown_map_districts.png`.
abstract final class BayhavenMapAnchors {
  static const cityHall = CityMapAnchor(
    id: 'city_hall',
    labelKey: 'mayor_office',
    label: 'Mayor\'s Office / City Hall',
    type: CityMapAnchorType.civic,
    district: CitySimulationDistrict.civicCenter,
    x: .50,
    y: .43,
    landmark: true,
  );
  static const civicCenter = CityMapAnchor(
    id: 'civic_center',
    labelKey: 'civic_center',
    label: 'Civic Center',
    type: CityMapAnchorType.civic,
    district: CitySimulationDistrict.civicCenter,
    x: .50,
    y: .46,
  );
  static const centralAvenue = CityMapAnchor(
    id: 'central_avenue',
    labelKey: 'central_avenue',
    label: 'Central Avenue',
    type: CityMapAnchorType.road,
    district: CitySimulationDistrict.civicCenter,
    x: .50,
    y: .55,
  );
  static const cityPlaza = CityMapAnchor(
    id: 'city_plaza',
    labelKey: 'city_plaza',
    label: 'City Plaza',
    type: CityMapAnchorType.park,
    district: CitySimulationDistrict.civicCenter,
    x: .50,
    y: .47,
    landmark: true,
  );
  static const governmentServicesCenter = CityMapAnchor(
    id: 'government_services_center',
    labelKey: 'government_services_center',
    label: 'Government Services Center',
    type: CityMapAnchorType.civic,
    district: CitySimulationDistrict.civicCenter,
    x: .40,
    y: .43,
    landmark: true,
  );
  static const newsHeadquarters = CityMapAnchor(
    id: 'news_headquarters',
    labelKey: 'news_headquarters',
    label: 'News Headquarters',
    type: CityMapAnchorType.media,
    district: CitySimulationDistrict.civicCenter,
    x: .59,
    y: .41,
    landmark: true,
  );

  static const riverside = CityMapAnchor(
    id: 'riverside',
    labelKey: 'riverside',
    label: 'Riverside',
    type: CityMapAnchorType.park,
    district: CitySimulationDistrict.riverside,
    x: .33,
    y: .66,
  );
  static const riversideCommunity = CityMapAnchor(
    id: 'riverside_community',
    labelKey: 'riverside_community',
    label: 'Riverside Community',
    type: CityMapAnchorType.residential,
    district: CitySimulationDistrict.riverside,
    x: .27,
    y: .46,
    landmark: true,
  );
  static const waterFacility = CityMapAnchor(
    id: 'water_facility',
    labelKey: 'water_facility',
    label: 'Water Facility',
    type: CityMapAnchorType.utility,
    district: CitySimulationDistrict.riverside,
    x: .08,
    y: .40,
    landmark: true,
  );
  static const westResidential = CityMapAnchor(
    id: 'west_residential',
    labelKey: 'west_residential',
    label: 'West Residential',
    type: CityMapAnchorType.residential,
    district: CitySimulationDistrict.riverside,
    x: .18,
    y: .34,
  );

  static const hospital = CityMapAnchor(
    id: 'hospital',
    labelKey: 'public_hospital',
    label: 'Public Hospital',
    type: CityMapAnchorType.health,
    district: CitySimulationDistrict.northWard,
    x: .40,
    y: .10,
    landmark: true,
  );
  static const northResidential = CityMapAnchor(
    id: 'north_residential',
    labelKey: 'north_residential',
    label: 'North Residential',
    type: CityMapAnchorType.residential,
    district: CitySimulationDistrict.northWard,
    x: .34,
    y: .23,
  );
  static const university = CityMapAnchor(
    id: 'university',
    labelKey: 'university',
    label: 'Bayhaven University',
    type: CityMapAnchorType.education,
    district: CitySimulationDistrict.northWard,
    x: .55,
    y: .10,
    landmark: true,
  );
  static const subdivisionArea = CityMapAnchor(
    id: 'subdivision_area',
    labelKey: 'subdivision_area',
    label: 'Gated Subdivision',
    type: CityMapAnchorType.residential,
    district: CitySimulationDistrict.northWard,
    x: .88,
    y: .10,
    landmark: true,
  );

  static const schoolDistrict = CityMapAnchor(
    id: 'school_district',
    labelKey: 'school_district',
    label: 'School District',
    type: CityMapAnchorType.education,
    district: CitySimulationDistrict.hillview,
    x: .57,
    y: .33,
    landmark: true,
  );
  static const eastResidential = CityMapAnchor(
    id: 'east_residential',
    labelKey: 'east_residential',
    label: 'East Residential',
    type: CityMapAnchorType.residential,
    district: CitySimulationDistrict.hillview,
    x: .90,
    y: .50,
  );
  static const policeHq = CityMapAnchor(
    id: 'police_hq',
    labelKey: 'police_hq',
    label: 'Police Headquarters',
    type: CityMapAnchorType.publicSafety,
    district: CitySimulationDistrict.hillview,
    x: .85,
    y: .30,
    landmark: true,
  );

  static const publicMarket = CityMapAnchor(
    id: 'public_market',
    labelKey: 'public_market',
    label: 'Public Market',
    type: CityMapAnchorType.market,
    district: CitySimulationDistrict.oldMarket,
    x: .62,
    y: .52,
    landmark: true,
  );
  static const commercialCenter = CityMapAnchor(
    id: 'commercial_center',
    labelKey: 'commercial_center',
    label: 'Commercial Center',
    type: CityMapAnchorType.commercial,
    district: CitySimulationDistrict.oldMarket,
    x: .70,
    y: .49,
  );
  static const shoppingMall = CityMapAnchor(
    id: 'shopping_mall',
    labelKey: 'shopping_mall',
    label: 'Bayhaven Mall',
    type: CityMapAnchorType.commercial,
    district: CitySimulationDistrict.oldMarket,
    x: .75,
    y: .38,
    landmark: true,
  );
  static const wasteSegregationCenter = CityMapAnchor(
    id: 'waste_segregation_center',
    labelKey: 'waste_segregation_center',
    label: 'Waste Segregation Center',
    type: CityMapAnchorType.sanitation,
    district: CitySimulationDistrict.oldMarket,
    x: .94,
    y: .62,
    landmark: true,
  );

  static const transportTerminal = CityMapAnchor(
    id: 'transport_terminal',
    labelKey: 'transport_terminal',
    label: 'Transport Terminal',
    type: CityMapAnchorType.transport,
    district: CitySimulationDistrict.harborDistrict,
    x: .51,
    y: .63,
    landmark: true,
  );
  static const warehouseLogistics = CityMapAnchor(
    id: 'warehouse_logistics',
    labelKey: 'warehouse_logistics',
    label: 'Warehouse & Logistics',
    type: CityMapAnchorType.logistics,
    district: CitySimulationDistrict.harborDistrict,
    x: .82,
    y: .65,
    landmark: true,
  );

  static const southResidential = CityMapAnchor(
    id: 'south_residential',
    labelKey: 'south_residential',
    label: 'South Residential',
    type: CityMapAnchorType.residential,
    district: CitySimulationDistrict.southPoint,
    x: .44,
    y: .75,
  );
  static const fireDisasterCenter = CityMapAnchor(
    id: 'fire_disaster_center',
    labelKey: 'fire_disaster_center',
    label: 'Fire & Disaster Center',
    type: CityMapAnchorType.emergency,
    district: CitySimulationDistrict.southPoint,
    x: .59,
    y: .79,
    landmark: true,
  );
  static const communitySportsArea = CityMapAnchor(
    id: 'community_sports_area',
    labelKey: 'community_sports_area',
    label: 'Community Sports Center',
    type: CityMapAnchorType.recreation,
    district: CitySimulationDistrict.southPoint,
    x: .50,
    y: .90,
    landmark: true,
  );

  static const industrialZone = CityMapAnchor(
    id: 'industrial_zone',
    labelKey: 'industrial_zone',
    label: 'Industrial Zone',
    type: CityMapAnchorType.industrial,
    district: CitySimulationDistrict.industrialBelt,
    x: .72,
    y: .64,
    landmark: true,
  );

  static const all = <CityMapAnchor>[
    cityHall,
    civicCenter,
    centralAvenue,
    cityPlaza,
    governmentServicesCenter,
    newsHeadquarters,
    riverside,
    riversideCommunity,
    waterFacility,
    westResidential,
    hospital,
    northResidential,
    university,
    subdivisionArea,
    schoolDistrict,
    eastResidential,
    policeHq,
    publicMarket,
    commercialCenter,
    shoppingMall,
    wasteSegregationCenter,
    transportTerminal,
    warehouseLogistics,
    southResidential,
    fireDisasterCenter,
    communitySportsArea,
    industrialZone,
  ];

  static const persistentLandmarks = <CityMapAnchor>[
    cityHall,
    hospital,
    schoolDistrict,
    publicMarket,
    transportTerminal,
    newsHeadquarters,
    wasteSegregationCenter,
    subdivisionArea,
    shoppingMall,
    policeHq,
    fireDisasterCenter,
    waterFacility,
    governmentServicesCenter,
    cityPlaza,
    riversideCommunity,
    industrialZone,
    university,
    warehouseLogistics,
    communitySportsArea,
  ];

  static CityMapAnchor byId(String id) =>
      all.firstWhere((anchor) => anchor.id == id, orElse: () => cityHall);
}

const cityMapAnchors = BayhavenMapAnchors.all;

CityMapAnchor cityMapAnchorById(String id) => BayhavenMapAnchors.byId(id);
