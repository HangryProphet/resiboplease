enum EvidenceType {
  profile('Profile'),
  platform('Platform'),
  campaignAd('Campaign ad'),
  publicRecord('Public record'),
  budgetDocument('Budget document'),
  socialPost('Social post'),
  factCheck('Fact-check'),
  controversy('Controversy'),
  debateAnswer('Debate answer');

  const EvidenceType(this.label);

  final String label;
}

enum TruthStatus {
  verifiedTrue('Verified'),
  mostlyTrue('Mostly true'),
  partiallyTrue('Partially true'),
  misleading('Misleading'),
  unverified('Unverified'),
  falseClaim('False'),
  missingContext('Missing context');

  const TruthStatus(this.label);

  final String label;
}

class EvidenceItem {
  const EvidenceItem({
    required this.id,
    required this.type,
    required this.title,
    required this.source,
    required this.summary,
    required this.details,
    required this.truthStatus,
    required this.reliability,
  });

  final String id;
  final EvidenceType type;
  final String title;
  final String source;
  final String summary;
  final String details;
  final TruthStatus truthStatus;
  final int reliability;
}
