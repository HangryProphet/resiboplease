import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/resibo_theme.dart';
import '../../core/state/game_controller.dart';
import '../../domain/models/accountability_journal.dart';
import '../../l10n/l10n_extensions.dart';
import '../candidate_hub/widgets/candidate_image_slot.dart';
import '../city/widgets/city_brief_ui.dart';

enum _JournalFilter { all, delivered, unresolved }

class AccountabilityJournalScreen extends StatefulWidget {
  const AccountabilityJournalScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<AccountabilityJournalScreen> createState() =>
      _AccountabilityJournalScreenState();
}

class _AccountabilityJournalScreenState
    extends State<AccountabilityJournalScreen> {
  _JournalFilter _filter = _JournalFilter.all;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final journal = widget.controller.accountabilityJournal;
      final all = journal.promises.reversed.toList(growable: false);
      final displayed = all
          .where((record) {
            return switch (_filter) {
              _JournalFilter.all => true,
              _JournalFilter.delivered =>
                record.outcome == AccountabilityOutcome.delivered,
              _JournalFilter.unresolved =>
                record.outcome != AccountabilityOutcome.delivered,
            };
          })
          .toList(growable: false);
      final delivered = all
          .where((item) => item.outcome == AccountabilityOutcome.delivered)
          .length;
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
                  title: context.l10n.resiboNgBayan,
                  cityName: widget.controller.activeCityName,
                  showBallot: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('accountability_journal_scroll'),
                    padding: const EdgeInsets.fromLTRB(13, 17, 13, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _JournalSummary(
                              total: all.length,
                              delivered: delivered,
                              administrations: widget
                                  .controller
                                  .administrationHistory
                                  .length,
                            ),
                            const SizedBox(height: 15),
                            _FilterBar(
                              selected: _filter,
                              onSelected: (value) =>
                                  setState(() => _filter = value),
                            ),
                            if (journal.recurringPromises.isNotEmpty ||
                                journal.recurringControversies.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              _RecurringRecordsPanel(journal: journal),
                            ],
                            const SizedBox(height: 20),
                            if (displayed.isEmpty)
                              CityPaperPanel(
                                child: Text(
                                  all.isEmpty
                                      ? context.l10n.noHistoricalPromises
                                      : context.l10n.noPromisesInFilter,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: cityBriefInk,
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              for (final record in displayed)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 13),
                                  child: _PromiseReceiptCard(record: record),
                                ),
                          ],
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
    },
  );
}

class _RecurringRecordsPanel extends StatelessWidget {
  const _RecurringRecordsPanel({required this.journal});

  final AccountabilityJournal journal;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CitySectionTitle(
        title: context.l10n.recurringRecords,
        icon: Icons.repeat_rounded,
      ),
      const SizedBox(height: 5),
      Text(
        context.l10n.recurringRecordsDescription,
        style: const TextStyle(
          color: Color(0xFFB9C7CF),
          fontSize: 11,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 10),
      CityPaperPanel(
        child: Column(
          children: [
            for (final pattern in journal.recurringPromises)
              _RecurringRow(
                icon: Icons.campaign_rounded,
                title: context.l10n.repeatedPromise,
                body: '${pattern.candidateName}: ${pattern.promiseTitle}',
                terms: pattern.termNumbers,
              ),
            for (final pattern in journal.recurringControversies)
              _RecurringRow(
                icon: Icons.gavel_rounded,
                title: context.l10n.recurringControversy,
                body: '${pattern.candidateName}: ${pattern.controversyKind}',
                terms: pattern.termNumbers,
              ),
          ],
        ),
      ),
    ],
  );
}

class _RecurringRow extends StatelessWidget {
  const _RecurringRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.terms,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<int> terms;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: const Color(0xFF76512E),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: cityBriefInk, width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFFFFF0CB), size: 20),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: ResiboColors.mutedRed,
                  fontFamily: 'LilitaOne',
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  color: cityBriefInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.l10n.administrationsList(terms.join(', ')),
                style: const TextStyle(
                  color: Color(0xFF675946),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _JournalSummary extends StatelessWidget {
  const _JournalSummary({
    required this.total,
    required this.delivered,
    required this.administrations,
  });

  final int total;
  final int delivered;
  final int administrations;

  @override
  Widget build(BuildContext context) => CityPaperPanel(
    color: const Color(0xFFF2DFAE),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ResiboColors.mutedRed,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cityBriefInk, width: 2),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFFFFF0CB),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.publicAccountabilityJournal.toUpperCase(),
                    style: const TextStyle(
                      color: cityBriefInk,
                      fontFamily: 'LilitaOne',
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    context.l10n.accountabilityJournalDescription,
                    style: const TextStyle(
                      color: Color(0xFF675946),
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryStamp(
              value: '$total',
              label: context.l10n.promisesRecorded,
            ),
            _SummaryStamp(
              value: '$delivered',
              label: context.l10n.deliveredLabel,
            ),
            _SummaryStamp(
              value: '$administrations',
              label: context.l10n.administrationsRecorded,
            ),
          ],
        ),
      ],
    ),
  );
}

class _SummaryStamp extends StatelessWidget {
  const _SummaryStamp({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFE3D0A7),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: cityBriefInk, width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: ResiboColors.mutedRed,
            fontFamily: 'LuckiestGuy',
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: cityBriefInk,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final _JournalFilter selected;
  final ValueChanged<_JournalFilter> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 480;
      final buttons = [
        _FilterButton(
          buttonKey: const Key('journal_filter_all'),
          label: context.l10n.allPromises,
          selected: selected == _JournalFilter.all,
          onTap: () => onSelected(_JournalFilter.all),
        ),
        _FilterButton(
          buttonKey: const Key('journal_filter_delivered'),
          label: context.l10n.deliveredLabel,
          selected: selected == _JournalFilter.delivered,
          onTap: () => onSelected(_JournalFilter.delivered),
        ),
        _FilterButton(
          buttonKey: const Key('journal_filter_unresolved'),
          label: context.l10n.unresolvedPromises,
          selected: selected == _JournalFilter.unresolved,
          onTap: () => onSelected(_JournalFilter.unresolved),
        ),
      ];
      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < buttons.length; index++) ...[
              buttons[index],
              if (index != buttons.length - 1) const SizedBox(height: 7),
            ],
          ],
        );
      }
      return Row(
        children: [
          for (var index = 0; index < buttons.length; index++) ...[
            Expanded(child: buttons[index]),
            if (index != buttons.length - 1) const SizedBox(width: 8),
          ],
        ],
      );
    },
  );
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.buttonKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Key buttonKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      key: buttonKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: selected
                ? const [Color(0xFFB84B58), Color(0xFF7B2D38)]
                : const [Color(0xFF38576C), Color(0xFF21394B)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF07111D), width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black87, offset: Offset(0, 3)),
          ],
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFFF0CB),
            fontFamily: 'LilitaOne',
            fontSize: 13,
            shadows: [Shadow(color: Colors.black87, offset: Offset(1, 1))],
          ),
        ),
      ),
    ),
  );
}

class _PromiseReceiptCard extends StatelessWidget {
  const _PromiseReceiptCard({required this.record});

  final AccountabilityPromiseRecord record;

  @override
  Widget build(BuildContext context) {
    final color = _outcomeColor(record.outcome);
    return CityPaperPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(7),
              ),
              border: const Border(
                bottom: BorderSide(color: cityBriefInk, width: 2),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  height: 42,
                  child: CandidateImageSlot(
                    candidateId: record.candidateId,
                    assetKey: record.portraitAssetKey,
                    semanticLabel: record.candidateName,
                    color: color,
                    aspectRatio: 1,
                    borderRadius: 6,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n
                            .administrationNumber(record.termNumber)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFFFE3A4),
                          fontFamily: 'LilitaOne',
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        record.candidateName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                _OutcomeStamp(label: _outcomeLabel(context, record.outcome)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.promiseTitle.toUpperCase(),
                  style: const TextStyle(
                    color: cityBriefInk,
                    fontFamily: 'LilitaOne',
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '“${record.campaignWording}”',
                  style: const TextStyle(
                    color: Color(0xFF675946),
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7D7B5),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: cityBriefInk, width: 1.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.fact_check_rounded, color: color, size: 21),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          record.outcomeExplanation,
                          style: const TextStyle(
                            color: cityBriefInk,
                            fontSize: 11,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (record.projectTitle != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.projectTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: cityBriefInk,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${record.projectProgress}%',
                        style: TextStyle(
                          color: color,
                          fontFamily: 'LuckiestGuy',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: record.projectProgress / 100,
                      backgroundColor: const Color(0xFFD1C3A5),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
                if (record.evidenceIds.isNotEmpty) ...[
                  const SizedBox(height: 13),
                  CityActionButton(
                    buttonKey: Key('open_historical_evidence_${record.id}'),
                    label: context.l10n.openArchivedEvidence,
                    icon: Icons.find_in_page_rounded,
                    color: const Color(0xFF3277A0),
                    onPressed: () => context.go(
                      '/history/${record.termNumber}/evidence/${Uri.encodeComponent(record.evidenceIds.first)}',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeStamp extends StatelessWidget {
  const _OutcomeStamp({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 112),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xEFFFF0CB),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: cityBriefInk, width: 1.5),
    ),
    child: Text(
      label.toUpperCase(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: cityBriefInk,
        fontSize: 9,
        height: 1,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

Color _outcomeColor(AccountabilityOutcome outcome) => switch (outcome) {
  AccountabilityOutcome.delivered => ResiboColors.teal,
  AccountabilityOutcome.partiallyDelivered ||
  AccountabilityOutcome.inProgress => const Color(0xFF3277A0),
  AccountabilityOutcome.notStarted ||
  AccountabilityOutcome.delayed => const Color(0xFFC27B27),
  AccountabilityOutcome.abandoned ||
  AccountabilityOutcome.blocked => ResiboColors.mutedRed,
};

String _outcomeLabel(BuildContext context, AccountabilityOutcome outcome) =>
    switch (outcome) {
      AccountabilityOutcome.notStarted => context.l10n.promiseNotStarted,
      AccountabilityOutcome.inProgress => context.l10n.promiseInProgress,
      AccountabilityOutcome.partiallyDelivered =>
        context.l10n.promisePartiallyDelivered,
      AccountabilityOutcome.delivered => context.l10n.promiseDelivered,
      AccountabilityOutcome.delayed => context.l10n.promiseDelayed,
      AccountabilityOutcome.abandoned => context.l10n.promiseAbandoned,
      AccountabilityOutcome.blocked => context.l10n.promiseBlocked,
    };
