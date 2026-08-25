import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../domain/models/candidate_biography.dart';
import '../../../l10n/candidate_experience_localizations.dart';
import '../../dossier/widgets/dossier_ui.dart';
import '../../information/widgets/information_actions.dart';

class ThenNowCard extends StatefulWidget {
  const ThenNowCard({required this.comparison, this.onOpenEvidence, super.key});

  final CandidateStatementComparison comparison;
  final ValueChanged<String>? onOpenEvidence;

  @override
  State<ThenNowCard> createState() => _ThenNowCardState();
}

class _ThenNowCardState extends State<ThenNowCard> {
  var _showContext = false;

  @override
  Widget build(BuildContext context) => PaperPanel(
    borderWidth: 2,
    padding: const EdgeInsets.all(14),
    child: Column(
      key: Key('then_now_${widget.comparison.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.compare_arrows_rounded, color: ResiboColors.gold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${context.candidateStrings.thenLabel} VS ${context.candidateStrings.nowLabel}',
                style: const TextStyle(
                  color: dossierInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 540;
            final then = _StatementPanel(
              label: context.candidateStrings.thenLabel,
              year: widget.comparison.thenYear,
              text: widget.comparison.thenStatement,
              color: const Color(0xFF64727D),
            );
            final now = _StatementPanel(
              label: context.candidateStrings.nowLabel,
              year: widget.comparison.nowYear,
              text: widget.comparison.nowStatement,
              color: ResiboColors.mutedRed,
            );
            if (narrow) {
              return Column(children: [then, const SizedBox(height: 8), now]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: then),
                const SizedBox(width: 9),
                Expanded(child: now),
              ],
            );
          },
        ),
        const SizedBox(height: 9),
        _ContextToggle(
          key: Key('toggle_context_${widget.comparison.id}'),
          onPressed: () => setState(() => _showContext = !_showContext),
          expanded: _showContext,
          label: _showContext
              ? context.candidateStrings.hideContext
              : context.candidateStrings.viewContext,
        ),
        if (_showContext) ...[
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFE9DFC7),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.comparison.context,
                  style: const TextStyle(color: dossierInk, height: 1.4),
                ),
                const SizedBox(height: 7),
                Text(
                  context.candidateStrings.contextIsNotVerdict,
                  style: const TextStyle(
                    color: Color(0xFF6A6257),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (widget.onOpenEvidence != null) ...[
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final evidenceId in widget.comparison.evidenceIds)
                        InformationActionButton(
                          buttonKey: Key('then_now_evidence_$evidenceId'),
                          icon: Icons.receipt_long_rounded,
                          color: ResiboColors.teal,
                          label: context.candidateStrings.openEvidence,
                          onPressed: () => widget.onOpenEvidence!(evidenceId),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

class _ContextToggle extends StatelessWidget {
  const _ContextToggle({
    required this.label,
    required this.expanded,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF5D9), Color(0xFFE7D4A9)],
            ),
            border: Border.all(color: dossierInk, width: 2),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(color: Colors.black38, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                expanded ? Icons.expand_less : Icons.menu_book_rounded,
                size: 17,
                color: dossierInk,
              ),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: dossierInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StatementPanel extends StatelessWidget {
  const _StatementPanel({
    required this.label,
    required this.year,
    required this.text,
    required this.color,
  });
  final String label;
  final int year;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      border: Border.all(color: color, width: 1.5),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label · $year',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(color: dossierInk, height: 1.35)),
      ],
    ),
  );
}
