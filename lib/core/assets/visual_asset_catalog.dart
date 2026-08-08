/// Central lookup for authored visual assets.
///
/// Domain models keep stable semantic keys so simulation and saved data never
/// depend on file paths. The UI resolves those keys here and retains its coded
/// fallback when a future procedural key has no authored image yet.
abstract final class VisualAssetCatalog {
  static const Map<String, String> _issueAssets = {
    'issue_flooding': 'assets/images/events/typhoon_response.jpg',
    'issue_public_funds': 'assets/images/issues/public_funds.jpg',
    'issue_unfinished_roads': 'assets/images/issues/unfinished_roads.jpg',
    'issue_community_safety': 'assets/images/issues/community_safety.jpg',
    'issue_garbage': 'assets/images/issues/garbage.jpg',
    'issue_traffic': 'assets/images/events/transport_disruption.jpg',
    'issue_water': 'assets/images/events/water_emergency.jpg',
    'issue_healthcare': 'assets/images/events/clinic_outbreak.jpg',
    'issue_jobs': 'assets/images/events/jobs_shock.jpg',
    'issue_cost_of_living': 'assets/images/issues/cost_of_living.jpg',
    'issue_services': 'assets/images/issues/government_services.jpg',
    'issue_education': 'assets/images/issues/education.jpg',
  };

  static const Map<String, String> _informationAssets = {
    'citybook_maya_banner': 'assets/images/citybook/maya_banner.jpg',
    'citybook_julian_banner': 'assets/images/citybook/julian_banner.jpg',
    'citybook_victor_banner': 'assets/images/citybook/victor_banner.jpg',
    'citybook_maya_clinic_plan': 'assets/images/citybook/maya_clinic_plan.jpg',
    'citybook_julian_jobs_rally':
        'assets/images/citybook/julian_jobs_rally.jpg',
    'citybook_victor_water_plan':
        'assets/images/citybook/victor_water_plan.jpg',
  };

  static const Map<String, String> _evidenceAssets = {
    'maya_clinic_rally': 'assets/images/citybook/maya_clinic_plan.jpg',
    'maya_mobile_clinic_story': 'assets/images/events/clinic_outbreak.jpg',
    'maya_clinic_poster': 'assets/images/citybook/maya_clinic_plan.jpg',
    'julian_jobs_launch': 'assets/images/citybook/julian_jobs_rally.jpg',
    'julian_contract_files': 'assets/images/issues/public_funds.jpg',
    'victor_water_launch': 'assets/images/citybook/victor_water_plan.jpg',
    'victor_dam_post': 'assets/images/events/water_emergency.jpg',
  };

  static String? issue(String visualKey) => _issueAssets[visualKey];

  static String? information(String assetKey) {
    final direct = _informationAssets[assetKey];
    if (direct != null) return direct;

    if (assetKey.startsWith('news_')) {
      return issue(assetKey.substring('news_'.length));
    }
    return null;
  }

  static String? evidence(String assetKey) => _evidenceAssets[assetKey];
}
