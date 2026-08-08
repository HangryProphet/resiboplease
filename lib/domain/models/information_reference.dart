enum InformationArtifactKind {
  cityProblem,
  chronicleEntry,
  candidateBiography,
  candidateHistory,
  candidatePromise,
  debateMessage,
  cityBookPost,
  newsEvent,
  newsCoverage,
  evidence,
}

enum InformationRelationshipType {
  supports,
  contradicts,
  references,
  disputes,
  updates,
  addsContext,
  respondsTo,
  reportsOn,
  originatesFrom,
}

class InformationReference {
  const InformationReference({required this.kind, required this.id});

  final InformationArtifactKind kind;
  final String id;
}

class InformationRelationship {
  const InformationRelationship({
    required this.id,
    required this.from,
    required this.to,
    required this.type,
    required this.explanation,
  });

  final String id;
  final InformationReference from;
  final InformationReference to;
  final InformationRelationshipType type;
  final String explanation;
}
