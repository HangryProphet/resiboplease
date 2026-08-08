import 'city_problem.dart';

enum CandidateInformationFootprint {
  minimal,
  limited,
  normal,
  extensive,
  overexposed,
}

enum CandidateHistoryEventType {
  education,
  employment,
  publicService,
  election,
  project,
  accomplishment,
  failure,
  controversy,
  appointment,
  resignation,
  businessActivity,
  advocacy,
  personalEvent,
}

enum CandidatePublicVisibility { obscure, local, citywide, prominent }

enum CandidatePromiseComplexity {
  focusedProgram,
  multiAgency,
  capitalProject,
  structuralReform,
}

enum CandidateInformationKind {
  biographyStatement,
  historyEvent,
  promise,
  debateMessage,
  evidence,
  controversy,
}

enum CandidateRelationType {
  supports,
  contradicts,
  addsContext,
  references,
  updates,
  disputes,
  corrects,
  relatesTo,
}

class CandidateBiographyStatement {
  const CandidateBiographyStatement({
    required this.id,
    required this.text,
    this.evidenceIds = const [],
  });

  final String id;
  final String text;
  final List<String> evidenceIds;
}

class CandidateBiographySection {
  const CandidateBiographySection({
    required this.id,
    required this.title,
    required this.statements,
  });

  final String id;
  final String title;
  final List<CandidateBiographyStatement> statements;
}

class CandidateLifeEvent {
  const CandidateLifeEvent({
    required this.id,
    required this.year,
    required this.type,
    required this.title,
    required this.summary,
    required this.details,
    required this.publicVisibility,
    this.evidenceIds = const [],
    this.relatedIssueFamilies = const [],
  });

  final String id;
  final int year;
  final CandidateHistoryEventType type;
  final String title;
  final String summary;
  final String details;
  final List<String> evidenceIds;
  final List<CityIssueFamily> relatedIssueFamilies;
  final CandidatePublicVisibility publicVisibility;
}

class CandidateBiography {
  const CandidateBiography({
    required this.candidateId,
    required this.birthYear,
    required this.occupation,
    required this.education,
    required this.currentPosition,
    required this.publicServiceStartYear,
    required this.hometown,
    required this.previousPositions,
    required this.summary,
    required this.informationFootprint,
    required this.sections,
    required this.timeline,
  });

  final String candidateId;
  final int birthYear;
  final String occupation;
  final List<String> education;
  final String currentPosition;
  final int publicServiceStartYear;
  final String hometown;
  final List<String> previousPositions;
  final String summary;

  /// Content-generation metadata. This is never rendered as a rating.
  final CandidateInformationFootprint informationFootprint;
  final List<CandidateBiographySection> sections;
  final List<CandidateLifeEvent> timeline;

  int ageIn(int year) => year - birthYear;

  CandidateLifeEvent? eventById(String id) {
    for (final event in timeline) {
      if (event.id == id) return event;
    }
    return null;
  }
}

class CandidatePromise {
  const CandidatePromise({
    required this.id,
    required this.candidateId,
    required this.title,
    required this.candidateWording,
    required this.approach,
    required this.complexity,
    required this.relatedIssueFamilies,
    this.evidenceIds = const [],
    this.relatedHistoryEventIds = const [],
  });

  final String id;
  final String candidateId;
  final String title;
  final String candidateWording;
  final String approach;
  final CandidatePromiseComplexity complexity;
  final List<CityIssueFamily> relatedIssueFamilies;
  final List<String> evidenceIds;
  final List<String> relatedHistoryEventIds;
}

class CandidateStatementComparison {
  const CandidateStatementComparison({
    required this.id,
    required this.candidateId,
    required this.thenYear,
    required this.thenStatement,
    required this.nowYear,
    required this.nowStatement,
    required this.context,
    required this.evidenceIds,
    this.relatedPromiseId,
  });

  final String id;
  final String candidateId;
  final int thenYear;
  final String thenStatement;
  final int nowYear;
  final String nowStatement;
  final String context;
  final List<String> evidenceIds;
  final String? relatedPromiseId;
}

class CandidateInformationReference {
  const CandidateInformationReference({required this.kind, required this.id});

  final CandidateInformationKind kind;
  final String id;
}

class CandidateInformationRelation {
  const CandidateInformationRelation({
    required this.from,
    required this.to,
    required this.type,
    required this.explanation,
  });

  final CandidateInformationReference from;
  final CandidateInformationReference to;
  final CandidateRelationType type;
  final String explanation;
}
