import 'package:flutter/widgets.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/state/game_controller.dart';
import '../domain/models/candidate_dossier_profile.dart';
import '../domain/models/city_indicator.dart';
import '../domain/models/city_problem.dart';
import '../domain/models/city_run_configuration.dart';
import '../domain/models/evidence_item.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsEn();
}

extension AppLocalizationsHelpers on AppLocalizations {
  List<String> get menuSplashLines => [
    splash1,
    splash2,
    splash3,
    splash4,
    splash5,
    splash6,
    splash7,
    splash8,
    splash9,
    splash10,
    splash11,
    splash12,
  ];

  String languageLabel(AppLanguage value) => switch (value) {
    AppLanguage.system => languageSystem,
    AppLanguage.english => languageEnglish,
    AppLanguage.filipino => languageFilipino,
  };

  String languageDetails(AppLanguage value) => switch (value) {
    AppLanguage.system => languageSystemDescription,
    AppLanguage.english => languageEnglishDescription,
    AppLanguage.filipino => languageFilipinoDescription,
  };

  String pressureLabel(StartingPressure value) => switch (value) {
    StartingPressure.stable => pressureStable,
    StartingPressure.strained => pressureStrained,
    StartingPressure.crisis => pressureCrisis,
  };

  String pressureDescription(StartingPressure value) => switch (value) {
    StartingPressure.stable => pressureStableDescription,
    StartingPressure.strained => pressureStrainedDescription,
    StartingPressure.crisis => pressureCrisisDescription,
  };

  String concernLabel(CityConcern value) => switch (value) {
    CityConcern.food => concernFood,
    CityConcern.poverty => concernPoverty,
    CityConcern.health => concernHealth,
    CityConcern.education => concernEducation,
    CityConcern.water => concernWater,
    CityConcern.jobs => concernJobs,
    CityConcern.cityServices => concernServices,
    CityConcern.climate => concernClimate,
  };

  String concernDescription(CityConcern value) => switch (value) {
    CityConcern.food => concernFoodDescription,
    CityConcern.poverty => concernPovertyDescription,
    CityConcern.health => concernHealthDescription,
    CityConcern.education => concernEducationDescription,
    CityConcern.water => concernWaterDescription,
    CityConcern.jobs => concernJobsDescription,
    CityConcern.cityServices => concernServicesDescription,
    CityConcern.climate => concernClimateDescription,
  };

  String candidateFieldLabel(CandidateField value) => switch (value) {
    CandidateField.unproven => candidateUnproven,
    CandidateField.mixed => candidateMixed,
    CandidateField.seasoned => candidateSeasoned,
  };

  String candidateFieldDetails(CandidateField value) => switch (value) {
    CandidateField.unproven => candidateUnprovenDescription,
    CandidateField.mixed => candidateMixedDescription,
    CandidateField.seasoned => candidateSeasonedDescription,
  };

  String assistanceLabel(AssistanceMode value) => switch (value) {
    AssistanceMode.guided => assistanceGuided,
    AssistanceMode.standard => assistanceStandard,
  };

  String assistanceDescription(AssistanceMode value) => switch (value) {
    AssistanceMode.guided => assistanceGuidedDescription,
    AssistanceMode.standard => assistanceStandardDescription,
  };

  String noiseLabel(CampaignNoise value) => switch (value) {
    CampaignNoise.clear => noiseClear,
    CampaignNoise.typical => noiseTypical,
    CampaignNoise.noisy => noiseNoisy,
  };

  String noiseDescription(CampaignNoise value) => switch (value) {
    CampaignNoise.clear => noiseClearDescription,
    CampaignNoise.typical => noiseTypicalDescription,
    CampaignNoise.noisy => noiseNoisyDescription,
  };

  String investigationLabel(InvestigationTime value) => switch (value) {
    InvestigationTime.relaxed => investigationRelaxed,
    InvestigationTime.standard => investigationStandard,
    InvestigationTime.limited => investigationLimited,
  };

  String investigationDescription(InvestigationTime value) => switch (value) {
    InvestigationTime.relaxed => investigationRelaxedDescription,
    InvestigationTime.standard => investigationStandardDescription,
    InvestigationTime.limited => investigationLimitedDescription,
  };

  String indicatorLabel(CityIndicator value) => switch (value) {
    CityIndicator.foodSecurity => indicatorFoodSecurity,
    CityIndicator.povertyReduction => indicatorPovertyReduction,
    CityIndicator.publicHealth => indicatorPublicHealth,
    CityIndicator.educationQuality => indicatorEducationQuality,
    CityIndicator.waterSecurity => indicatorWaterSecurity,
    CityIndicator.employmentQuality => indicatorEmploymentQuality,
    CityIndicator.urbanResilience => indicatorUrbanResilience,
    CityIndicator.climateResilience => indicatorClimateResilience,
    CityIndicator.budgetHealth => indicatorBudgetHealth,
    CityIndicator.publicTrust => indicatorPublicTrust,
    CityIndicator.corruptionPressure => indicatorCorruptionPressure,
  };

  String indicatorStateLabel(int value) => switch (value) {
    <= 19 => stateCritical,
    <= 39 => statePoor,
    <= 59 => stateUnstable,
    <= 79 => stateFunctional,
    _ => stateStrong,
  };

  String trendLabel(ProblemTrend value) => switch (value) {
    ProblemTrend.improving => trendImproving,
    ProblemTrend.stable => trendStable,
    ProblemTrend.worsening => trendWorsening,
    ProblemTrend.rapidlyWorsening => trendRapidlyWorsening,
  };

  String evidenceTypeLabel(EvidenceType value) => switch (value) {
    EvidenceType.profile => evidenceProfile,
    EvidenceType.platform => evidencePlatform,
    EvidenceType.campaignAd => evidenceCampaignAd,
    EvidenceType.publicRecord => evidencePublicRecord,
    EvidenceType.budgetDocument => evidenceBudgetDocument,
    EvidenceType.socialPost => evidenceSocialPost,
    EvidenceType.factCheck => evidenceFactCheck,
    EvidenceType.controversy => evidenceControversy,
    EvidenceType.debateAnswer => evidenceDebateAnswer,
  };

  String truthStatusLabel(TruthStatus value) => switch (value) {
    TruthStatus.verifiedTrue => truthVerified,
    TruthStatus.mostlyTrue => truthMostlyTrue,
    TruthStatus.partiallyTrue => truthPartiallyTrue,
    TruthStatus.misleading => truthMisleading,
    TruthStatus.unverified => truthUnverified,
    TruthStatus.falseClaim => truthFalse,
    TruthStatus.missingContext => truthMissingContext,
  };

  String dossierExperienceLabel(DossierExperienceBand value) => switch (value) {
    DossierExperienceBand.emerging => experienceEmerging,
    DossierExperienceBand.practiced => experiencePracticed,
    DossierExperienceBand.established => experienceEstablished,
  };

  String dossierEvidenceDepthLabel(DossierEvidenceDepth value) =>
      switch (value) {
        DossierEvidenceDepth.limited => evidenceDepthLimited,
        DossierEvidenceDepth.mixed => evidenceDepthMixed,
        DossierEvidenceDepth.documented => evidenceDepthDocumented,
      };

  String runProgressLabel(CityRunProgress value) => switch (value) {
    CityRunProgress.electionBrief => electionBriefProgress,
    CityRunProgress.termInProgress => termInProgressProgress,
    CityRunProgress.termReportReady => termReportReadyProgress,
  };
}
