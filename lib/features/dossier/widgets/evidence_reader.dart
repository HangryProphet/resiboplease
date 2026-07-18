import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/state/game_controller.dart';
import '../../../domain/models/candidate.dart';
import '../../../domain/models/evidence_item.dart';
import '../../../l10n/game_content_localizations.dart';
import '../../../l10n/l10n_extensions.dart';
import 'dossier_ui.dart';

Future<bool> openEvidenceReader(
  BuildContext context, {
  required GameController controller,
  required Candidate candidate,
  required EvidenceItem item,
}) async {
  final canOpen = controller.markEvidenceViewed(item.id);
  if (!canOpen) {
    await _showNoPointsDialog(context);
    return false;
  }

  final reader = _EvidenceReader(
    controller: controller,
    candidate: candidate,
    item: item,
  );
  if (MediaQuery.sizeOf(context).width < 700) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC07111D),
      builder: (context) =>
          FractionallySizedBox(heightFactor: .94, child: reader),
    );
  } else {
    await showDialog<void>(
      context: context,
      barrierColor: const Color(0xCC07111D),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
          child: reader,
        ),
      ),
    );
  }
  return true;
}

Future<void> _showNoPointsDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierColor: const Color(0xCC07111D),
  builder: (context) => Dialog(
    key: const Key('no_investigation_points_dialog'),
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(22),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: PaperPanel(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_empty_rounded,
              color: ResiboColors.mutedRed,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.noInvestigationPoints.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: dossierInk,
                fontFamily: 'LuckiestGuy',
                fontSize: 25,
                height: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.noInvestigationPointsBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: dossierInk,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ChunkyActionButton(
                buttonKey: const Key('dismiss_no_points'),
                label: context.l10n.understood,
                color: ResiboColors.teal,
                compact: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

class _EvidenceReader extends StatefulWidget {
  const _EvidenceReader({
    required this.controller,
    required this.candidate,
    required this.item,
  });

  final GameController controller;
  final Candidate candidate;
  final EvidenceItem item;

  @override
  State<_EvidenceReader> createState() => _EvidenceReaderState();
}

class _EvidenceReaderState extends State<_EvidenceReader> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final controller = widget.controller;
    final cityName = controller.scenario.city.name;
    final candidateColor = Color(widget.candidate.colorValue);
    return Material(
      color: Colors.transparent,
      child: Container(
        key: Key('evidence_reader_${item.id}'),
        decoration: BoxDecoration(
          color: dossierPaper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dossierInk, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              offset: Offset(0, 8),
              blurRadius: 8,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(candidateColor, Colors.white, .12)!,
                    candidateColor,
                    Color.lerp(candidateColor, Colors.black, .22)!,
                  ],
                ),
                border: const Border(
                  bottom: BorderSide(color: dossierInk, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.evidenceTypeLabel(item.type).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFF1D1),
                        fontFamily: 'LilitaOne',
                        fontSize: 19,
                        letterSpacing: .7,
                        shadows: [
                          Shadow(color: Colors.black54, offset: Offset(1, 2)),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('close_evidence_reader_top'),
                    tooltip: context.l10n.close,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFFFF1D1),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.evidenceTitleText(item, cityName),
                            style: const TextStyle(
                              color: dossierInk,
                              fontFamily: 'LuckiestGuy',
                              fontSize: 28,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FileStamp(
                          label: context.l10n.fileOpened,
                          color: ResiboColors.teal,
                          icon: Icons.check_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7D7B5),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFF8D7956)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.apartment_rounded,
                            color: ResiboColors.teal,
                            size: 21,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.evidenceSourceText(item, cityName),
                              style: const TextStyle(
                                color: dossierInk,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.l10n.evidenceSummaryText(item, cityName),
                      style: const TextStyle(
                        color: dossierInk,
                        fontSize: 17,
                        height: 1.42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFF9D8B67), thickness: 1.2),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.evidenceDetailsText(item, cityName),
                      style: const TextStyle(
                        color: dossierInk,
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 22),
                    PaperPanel(
                      padding: const EdgeInsets.all(14),
                      color: const Color(0xFFE9E4C8),
                      borderWidth: 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(
                            label: context.l10n.sourceCheckTitle,
                            icon: Icons.manage_search_rounded,
                            color: ResiboColors.teal,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.sourceCheckBody,
                            style: const TextStyle(
                              color: dossierInk,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.sourceCue(
                              _reliabilityCue(context, item.reliability),
                            ),
                            key: const Key('evidence_source_cue'),
                            style: const TextStyle(
                              color: dossierInk,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (item.type == EvidenceType.factCheck) ...[
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.factCheckFinding(
                                context.l10n.truthStatusLabel(item.truthStatus),
                              ),
                              key: const Key('fact_check_finding'),
                              style: const TextStyle(
                                color: dossierInk,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChunkyActionButton(
                          buttonKey: Key('bookmark_${item.id}'),
                          label: controller.isBookmarked(item.id)
                              ? context.l10n.removeBookmark
                              : context.l10n.bookmark,
                          icon: controller.isBookmarked(item.id)
                              ? Icons.bookmark_remove_rounded
                              : Icons.bookmark_add_rounded,
                          color: ResiboColors.gold,
                          compact: true,
                          onPressed: () {
                            controller.toggleBookmark(item.id);
                            setState(() {});
                          },
                        ),
                        ChunkyActionButton(
                          buttonKey: const Key('close_evidence_reader_bottom'),
                          label: context.l10n.close,
                          icon: Icons.check_rounded,
                          color: ResiboColors.teal,
                          compact: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _reliabilityCue(BuildContext context, int reliability) =>
      switch (reliability) {
        >= 80 => context.l10n.reliabilityStrong,
        >= 60 => context.l10n.reliabilityModerate,
        _ => context.l10n.reliabilityWeak,
      };
}
