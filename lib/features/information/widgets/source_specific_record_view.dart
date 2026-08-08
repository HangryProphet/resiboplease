import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/state/game_controller.dart';
import '../../../domain/models/candidate.dart';
import '../../../domain/models/evidence_item.dart';
import '../../../l10n/information_ecosystem_localizations.dart';
import '../../dossier/widgets/dossier_ui.dart';
import 'information_media_slots.dart';

class SourceSpecificEvidenceView extends StatelessWidget {
  const SourceSpecificEvidenceView({
    required this.controller,
    required this.candidate,
    required this.item,
    super.key,
  });

  final GameController controller;
  final Candidate candidate;
  final EvidenceItem item;

  @override
  Widget build(BuildContext context) => Column(
    key: Key('source_specific_${item.id}'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      switch (item.type) {
        EvidenceType.publicRecord => TransparencyRecordView(
          item: item,
          candidate: candidate,
        ),
        EvidenceType.budgetDocument => _BudgetDocumentView(item: item),
        EvidenceType.socialPost => _SocialRecordView(
          controller: controller,
          candidate: candidate,
          item: item,
        ),
        EvidenceType.campaignAd => _CampaignRecordView(
          candidate: candidate,
          item: item,
        ),
        EvidenceType.factCheck => _FactCheckRecordView(item: item),
        EvidenceType.debateAnswer => _DebateRecordView(
          candidate: candidate,
          item: item,
        ),
        EvidenceType.controversy => _InvestigationRecordView(item: item),
        EvidenceType.platform => _PlatformRecordView(item: item),
        EvidenceType.profile => _ArchiveRecordView(item: item),
      },
      const SizedBox(height: 7),
      Text(
        context.informationStrings.normalizedReaderNote,
        style: const TextStyle(
          color: Color(0xFF6A6257),
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
      ),
    ],
  );
}

class TransparencyRecordView extends StatelessWidget {
  const TransparencyRecordView({
    required this.item,
    required this.candidate,
    super.key,
  });
  final EvidenceItem item;
  final Candidate candidate;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('transparency_portal_record'),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F6F3),
      border: Border.all(color: const Color(0xFF1E6859), width: 2),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: const Color(0xFF1E6859),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.account_balance_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.informationStrings.transparencyPortal.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'LilitaOne',
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.informationStrings.publicRecord.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1E6859),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.title,
                style: const TextStyle(
                  color: dossierInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              _RecordRow(
                label: context.informationStrings.recordId,
                value: item.id.toUpperCase(),
              ),
              _RecordRow(
                label: context.informationStrings.issuingOffice,
                value: item.source,
              ),
              _RecordRow(label: 'Named candidate', value: candidate.name),
              _RecordRow(
                label: context.informationStrings.recordStatus,
                value: context.informationStrings.available,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5A6A62),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: dossierInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _BudgetDocumentView extends StatelessWidget {
  const _BudgetDocumentView({required this.item});
  final EvidenceItem item;
  @override
  Widget build(BuildContext context) => _DocumentShell(
    key: const Key('budget_document_presentation'),
    color: const Color(0xFF8A681E),
    icon: Icons.calculate_rounded,
    eyebrow: 'FISCAL REVIEW · BUDGET DOCUMENT',
    title: item.title,
    body: item.summary,
  );
}

class _SocialRecordView extends StatelessWidget {
  const _SocialRecordView({
    required this.controller,
    required this.candidate,
    required this.item,
  });
  final GameController controller;
  final Candidate candidate;
  final EvidenceItem item;
  @override
  Widget build(BuildContext context) {
    final posts = controller.informationEcosystem.cityBook.postsFor(
      candidate.id,
    );
    final linked = posts
        .where((post) => post.relatedEvidenceIds.contains(item.id))
        .firstOrNull;
    return _DocumentShell(
      key: const Key('citybook_evidence_presentation'),
      color: const Color(0xFF3F78A8),
      icon: Icons.public_rounded,
      eyebrow: 'CITYBOOK · PUBLIC CLAIM',
      title: linked == null ? item.title : candidate.name,
      body: linked?.text ?? item.summary,
    );
  }
}

class _CampaignRecordView extends StatelessWidget {
  const _CampaignRecordView({required this.candidate, required this.item});
  final Candidate candidate;
  final EvidenceItem item;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(7),
    child: Column(
      children: [
        SocialMediaImageSlot(
          assetKey: 'campaign_${item.id}',
          semanticLabel: 'Reserved campaign media',
          aspectRatio: 4 / 5,
          color: Color(candidate.colorValue),
        ),
        Container(
          width: double.infinity,
          color: Color(candidate.colorValue),
          padding: const EdgeInsets.all(12),
          child: Text(
            item.summary,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFF1D1),
              fontFamily: 'LilitaOne',
              fontSize: 18,
            ),
          ),
        ),
      ],
    ),
  );
}

class _FactCheckRecordView extends StatelessWidget {
  const _FactCheckRecordView({required this.item});
  final EvidenceItem item;
  @override
  Widget build(BuildContext context) => _DocumentShell(
    key: const Key('fact_check_presentation'),
    color: const Color(0xFF397B55),
    icon: Icons.fact_check_rounded,
    eyebrow: 'CLAIM REVIEW · ${item.truthStatus.label.toUpperCase()}',
    title: item.title,
    body: item.summary,
  );
}

class _DebateRecordView extends StatelessWidget {
  const _DebateRecordView({required this.candidate, required this.item});
  final Candidate candidate;
  final EvidenceItem item;
  @override
  Widget build(BuildContext context) => _DocumentShell(
    key: const Key('debate_record_presentation'),
    color: Color(candidate.colorValue),
    icon: Icons.forum_rounded,
    eyebrow: 'DEBATE TRANSCRIPT · ${candidate.name.toUpperCase()}',
    title: item.title,
    body: '“${item.summary}”',
  );
}

class _InvestigationRecordView extends StatelessWidget {
  const _InvestigationRecordView({required this.item});
  final EvidenceItem item;
  @override
  Widget build(BuildContext context) => _DocumentShell(
    key: const Key('investigation_record_presentation'),
    color: ResiboColors.mutedRed,
    icon: Icons.manage_search_rounded,
    eyebrow: 'INVESTIGATIVE SUMMARY · QUESTIONS REMAIN',
    title: item.title,
    body: item.summary,
  );
}

class _PlatformRecordView extends StatelessWidget {
  const _PlatformRecordView({required this.item});
  final EvidenceItem item;
  @override
  Widget build(BuildContext context) => _DocumentShell(
    color: ResiboColors.mutedRed,
    icon: Icons.campaign_rounded,
    eyebrow: 'CAMPAIGN PLATFORM · STATEMENT OF INTENT',
    title: item.title,
    body: item.summary,
  );
}

class _ArchiveRecordView extends StatelessWidget {
  const _ArchiveRecordView({required this.item});
  final EvidenceItem item;
  @override
  Widget build(BuildContext context) => _DocumentShell(
    color: const Color(0xFF5E4B87),
    icon: Icons.badge_rounded,
    eyebrow: 'CIVIC ARCHIVE · PROFILE RECORD',
    title: item.title,
    body: item.summary,
  );
}

class _DocumentShell extends StatelessWidget {
  const _DocumentShell({
    required this.color,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    super.key,
  });
  final Color color;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      border: Border.all(color: color, width: 2),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: dossierInk,
                  fontFamily: 'LilitaOne',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(color: dossierInk, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
