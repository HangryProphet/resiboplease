import 'package:flutter/material.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/evidence_item.dart';
import '../../domain/models/political_timeline.dart';
import '../../l10n/l10n_extensions.dart';
import '../candidate_hub/widgets/candidate_image_slot.dart';
import '../city/widgets/city_brief_ui.dart';

class HistoricalEvidenceScreen extends StatelessWidget {
  const HistoricalEvidenceScreen({
    required this.controller,
    required this.termNumber,
    required this.evidenceId,
    super.key,
  });

  final GameController controller;
  final int termNumber;
  final String evidenceId;

  @override
  Widget build(BuildContext context) {
    final record = controller.administrationHistory
        .where((item) => item.termNumber == termNumber)
        .firstOrNull;
    final candidate = record?.election?.candidates
        .where((item) => item.id == record.electedCandidateId)
        .firstOrNull;
    final evidence = candidate?.evidence
        .where((item) => item.id == evidenceId)
        .firstOrNull;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1725),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF172B3E), Color(0xFF08121D)],
            ),
          ),
          child: Column(
            children: [
              CityBriefHeader(
                title: context.l10n.historicalEvidence,
                cityName: controller.activeCityName,
                showBallot: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('historical_evidence_scroll'),
                  padding: const EdgeInsets.fromLTRB(13, 17, 13, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: evidence == null || record == null
                          ? _MissingEvidence()
                          : _EvidenceReceipt(
                              record: record,
                              evidence: evidence,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissingEvidence extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CityPaperPanel(
    child: Column(
      children: [
        const Icon(
          Icons.find_in_page_rounded,
          color: ResiboColors.mutedRed,
          size: 44,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.historicalEvidenceMissing,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: cityBriefInk,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _EvidenceReceipt extends StatelessWidget {
  const _EvidenceReceipt({required this.record, required this.evidence});

  final AdministrationRecord record;
  final EvidenceItem evidence;

  @override
  Widget build(BuildContext context) {
    final truthColor = switch (evidence.truthStatus) {
      TruthStatus.verifiedTrue || TruthStatus.mostlyTrue => ResiboColors.teal,
      TruthStatus.partiallyTrue ||
      TruthStatus.missingContext ||
      TruthStatus.unverified => const Color(0xFFC27B27),
      TruthStatus.misleading || TruthStatus.falseClaim => ResiboColors.mutedRed,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF38576C), Color(0xFF172B3E)],
            ),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFF07111D), width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black87, offset: Offset(0, 6)),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 82,
                child: CandidateImageSlot(
                  candidateId: record.electedCandidateId,
                  assetKey: record.electedPortraitAssetKey,
                  semanticLabel: record.electedCandidateName,
                  color: ResiboColors.teal,
                  aspectRatio: 72 / 82,
                  borderRadius: 7,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n
                          .administrationNumber(record.termNumber)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFD36B),
                        fontFamily: 'LilitaOne',
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.electedCandidateName.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFF0CB),
                        fontFamily: 'LuckiestGuy',
                        fontSize: 20,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.archivedElectionSnapshot,
                      style: const TextStyle(
                        color: Color(0xFFC4D1D8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CityPaperPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n
                          .evidenceTypeLabel(evidence.type)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: ResiboColors.mutedRed,
                        fontFamily: 'LilitaOne',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: truthColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: cityBriefInk, width: 1.5),
                    ),
                    child: Text(
                      context.l10n.truthStatusLabel(evidence.truthStatus),
                      style: const TextStyle(
                        color: Color(0xFFFFF0CB),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                evidence.title,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 23,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                evidence.source,
                style: const TextStyle(
                  color: Color(0xFF675946),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                evidence.summary,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontWeight: FontWeight.w900,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                evidence.details,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7D7B5),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: cityBriefInk, width: 1.5),
                ),
                child: Text(
                  context.l10n.historicalEvidenceNotice,
                  style: const TextStyle(
                    color: Color(0xFF675946),
                    fontSize: 10,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
