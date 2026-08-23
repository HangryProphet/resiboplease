enum CandidateGender { male, female }

enum CandidateAgeGroup { youngAdult, middleAged, olderAdult }

/// Reusable visual identity. Portraits are deliberately not bound to names.
class CandidatePortrait {
  const CandidatePortrait({
    required this.id,
    required this.assetPath,
    required this.gender,
    required this.ageGroup,
    required this.styleKey,
  });

  final String id;
  final String assetPath;
  final CandidateGender gender;
  final CandidateAgeGroup ageGroup;
  final String styleKey;
}

/// Exactly seven reusable portrait identities. A world selects five without
/// replacement, then assigns gender-compatible first names.
const candidatePortraitPool = <CandidatePortrait>[
  CandidatePortrait(
    id: 'portrait_01',
    assetPath: 'assets/images/candidates/maya_vargas/maya_vargas_portrait.png',
    gender: CandidateGender.female,
    ageGroup: CandidateAgeGroup.middleAged,
    styleKey: 'poised_reformer',
  ),
  CandidatePortrait(
    id: 'portrait_02',
    assetPath:
        'assets/images/candidates/julian_pratt/julian_pratt_portrait.png',
    gender: CandidateGender.male,
    ageGroup: CandidateAgeGroup.middleAged,
    styleKey: 'confident_executive',
  ),
  CandidatePortrait(
    id: 'portrait_03',
    assetPath: 'assets/images/candidates/victor_chen/victor_chen_portrait.png',
    gender: CandidateGender.male,
    ageGroup: CandidateAgeGroup.olderAdult,
    styleKey: 'reserved_professional',
  ),
  CandidatePortrait(
    id: 'portrait_04',
    assetPath: 'assets/images/candidates/portrait_04.png',
    gender: CandidateGender.female,
    ageGroup: CandidateAgeGroup.youngAdult,
    styleKey: 'community_organizer',
  ),
  CandidatePortrait(
    id: 'portrait_05',
    assetPath: 'assets/images/candidates/portrait_05.png',
    gender: CandidateGender.male,
    ageGroup: CandidateAgeGroup.youngAdult,
    styleKey: 'media_outsider',
  ),
  CandidatePortrait(
    id: 'portrait_06',
    assetPath: 'assets/images/candidates/portrait_06.png',
    gender: CandidateGender.female,
    ageGroup: CandidateAgeGroup.olderAdult,
    styleKey: 'seasoned_administrator',
  ),
  CandidatePortrait(
    id: 'portrait_07',
    assetPath: 'assets/images/candidates/portrait_07.png',
    gender: CandidateGender.male,
    ageGroup: CandidateAgeGroup.middleAged,
    styleKey: 'technical_specialist',
  ),
];

CandidatePortrait? candidatePortraitById(String id) {
  for (final portrait in candidatePortraitPool) {
    if (portrait.id == id) return portrait;
  }
  return null;
}
