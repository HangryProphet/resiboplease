import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../domain/models/city_run_configuration.dart';
import '../../../l10n/l10n_extensions.dart';
import 'game_overlay_shell.dart';

class CityConfigurationForm extends StatefulWidget {
  const CityConfigurationForm({
    required this.slotIndex,
    required this.onSubmit,
    required this.onBack,
    super.key,
  });

  final int slotIndex;
  final ValueChanged<CityRunConfiguration> onSubmit;
  final VoidCallback onBack;

  @override
  State<CityConfigurationForm> createState() => _CityConfigurationFormState();
}

class _CityConfigurationFormState extends State<CityConfigurationForm> {
  final TextEditingController _cityNameController = TextEditingController();
  final Set<CityConcern> _mainConcerns = {
    CityConcern.water,
    CityConcern.jobs,
    CityConcern.health,
  };

  StartingPressure _startingPressure = StartingPressure.strained;
  CandidateField _candidateField = CandidateField.mixed;
  AssistanceMode _assistanceMode = AssistanceMode.guided;
  CampaignNoise _campaignNoise = CampaignNoise.typical;
  InvestigationTime _investigationTime = InvestigationTime.standard;
  String? _nameError;
  String? _concernMessage;

  @override
  void dispose() {
    _cityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(
    key: const Key('city_configuration_page'),
    child: ListView(
      key: const Key('city_name_page'),
      padding: const EdgeInsets.fromLTRB(17, 5, 17, 25),
      children: [
        Center(
          child: InkStamp(
            text: context.l10n.saveSlotNumber(widget.slotIndex + 1),
            color: ResiboColors.navy,
            angle: -.025,
          ),
        ),
        const SizedBox(height: 14),
        const _SetupIntro(),
        const SizedBox(height: 13),
        _SetupSection(
          number: 1,
          title: context.l10n.cityName,
          subtitle: context.l10n.cityNameDescription,
          child: TextField(
            key: const Key('city_name_field'),
            controller: _cityNameController,
            textCapitalization: TextCapitalization.words,
            maxLength: 24,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
            onSubmitted: (_) => _submit(),
            style: const TextStyle(
              color: ResiboColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            decoration: _fieldDecoration(
              hintText: context.l10n.cityNameHint,
              errorText: _nameError,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ChoiceSection<StartingPressure>(
          number: 2,
          title: context.l10n.startingPressure,
          subtitle: context.l10n.startingPressureDescription,
          values: StartingPressure.values,
          selected: _startingPressure,
          labelOf: context.l10n.pressureLabel,
          descriptionOf: context.l10n.pressureDescription,
          iconOf: _pressureIcon,
          keyOf: (value) => Key('starting_pressure_${value.name}'),
          onSelected: (value) => setState(() => _startingPressure = value),
        ),
        const SizedBox(height: 12),
        _SetupSection(
          number: 3,
          title: context.l10n.mainConcerns,
          subtitle: context.l10n.mainConcernsDescription,
          trailing: InkStamp(
            text: context.l10n.selectedConcernCount(_mainConcerns.length),
            color: _mainConcerns.length == 3
                ? ResiboColors.mutedRed
                : ResiboColors.teal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 470;
                  final width = twoColumns
                      ? (constraints.maxWidth - 9) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      for (final concern in CityConcern.values)
                        SizedBox(
                          width: width,
                          child: _ConcernChoice(
                            concern: concern,
                            selected: _mainConcerns.contains(concern),
                            onPressed: () => _toggleConcern(concern),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (_concernMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _concernMessage!,
                  key: const Key('concern_selection_message'),
                  style: const TextStyle(
                    color: ResiboColors.mutedRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChoiceSection<CandidateField>(
          number: 4,
          title: context.l10n.candidateField,
          subtitle: context.l10n.candidateFieldDescription,
          values: CandidateField.values,
          selected: _candidateField,
          labelOf: context.l10n.candidateFieldLabel,
          descriptionOf: context.l10n.candidateFieldDetails,
          iconOf: (value) => switch (value) {
            CandidateField.unproven => Icons.new_releases_outlined,
            CandidateField.mixed => Icons.groups_2_outlined,
            CandidateField.seasoned => Icons.workspace_premium_outlined,
          },
          keyOf: (value) => Key('candidate_field_${value.name}'),
          onSelected: (value) => setState(() => _candidateField = value),
        ),
        const SizedBox(height: 12),
        _ChoiceSection<AssistanceMode>(
          number: 5,
          title: context.l10n.assistanceMode,
          subtitle: context.l10n.assistanceModeDescription,
          values: AssistanceMode.values,
          selected: _assistanceMode,
          labelOf: context.l10n.assistanceLabel,
          descriptionOf: context.l10n.assistanceDescription,
          iconOf: (value) => value == AssistanceMode.guided
              ? Icons.assistant_outlined
              : Icons.explore_outlined,
          keyOf: (value) => Key('assistance_mode_${value.name}'),
          onSelected: (value) => setState(() => _assistanceMode = value),
        ),
        const SizedBox(height: 12),
        _ChoiceSection<CampaignNoise>(
          number: 6,
          title: context.l10n.campaignNoise,
          subtitle: context.l10n.campaignNoiseDescription,
          values: CampaignNoise.values,
          selected: _campaignNoise,
          labelOf: context.l10n.noiseLabel,
          descriptionOf: context.l10n.noiseDescription,
          iconOf: (value) => switch (value) {
            CampaignNoise.clear => Icons.fact_check_outlined,
            CampaignNoise.typical => Icons.campaign_outlined,
            CampaignNoise.noisy => Icons.record_voice_over_outlined,
          },
          keyOf: (value) => Key('campaign_noise_${value.name}'),
          onSelected: (value) => setState(() => _campaignNoise = value),
        ),
        const SizedBox(height: 12),
        _ChoiceSection<InvestigationTime>(
          number: 7,
          title: context.l10n.investigationTime,
          subtitle: context.l10n.investigationTimeDescription,
          values: InvestigationTime.values,
          selected: _investigationTime,
          labelOf: context.l10n.investigationLabel,
          descriptionOf: context.l10n.investigationDescription,
          iconOf: (value) => switch (value) {
            InvestigationTime.relaxed => Icons.all_inclusive_rounded,
            InvestigationTime.standard => Icons.timer_outlined,
            InvestigationTime.limited => Icons.hourglass_bottom_rounded,
          },
          keyOf: (value) => Key('investigation_time_${value.name}'),
          onSelected: (value) => setState(() => _investigationTime = value),
        ),
        const SizedBox(height: 14),
        _ConfigurationSummary(
          pressure: _startingPressure,
          concerns: _mainConcerns,
          candidateField: _candidateField,
          assistanceMode: _assistanceMode,
          campaignNoise: _campaignNoise,
          investigationTime: _investigationTime,
        ),
        const SizedBox(height: 18),
        ChunkyPaperButton(
          label: context.l10n.openCityFile,
          icon: Icons.folder_open_rounded,
          color: const Color(0xFF3E783A),
          buttonKey: const Key('create_city_submit'),
          onPressed: _submit,
        ),
        const SizedBox(height: 11),
        ChunkyPaperButton(
          label: context.l10n.backToSaveSlots,
          icon: Icons.arrow_back_rounded,
          color: ResiboColors.navy,
          buttonKey: const Key('back_to_save_slots'),
          onPressed: widget.onBack,
        ),
      ],
    ),
  );

  InputDecoration _fieldDecoration({String? hintText, String? errorText}) =>
      InputDecoration(
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFFFFCF1),
        counterStyle: const TextStyle(color: Color(0xFF725B40)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF594127), width: 2),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: ResiboColors.teal, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: ResiboColors.mutedRed, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: ResiboColors.mutedRed, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
      );

  void _toggleConcern(CityConcern concern) {
    setState(() {
      if (_mainConcerns.contains(concern)) {
        if (_mainConcerns.length == 1) {
          _concernMessage = context.l10n.keepOneConcern;
          return;
        }
        _mainConcerns.remove(concern);
        _concernMessage = null;
        return;
      }
      if (_mainConcerns.length == 3) {
        _concernMessage = context.l10n.removeConcernFirst;
        return;
      }
      _mainConcerns.add(concern);
      _concernMessage = null;
    });
  }

  void _submit() {
    final name = _cityNameController.text.trim();
    if (name.length < 2) {
      setState(() => _nameError = context.l10n.cityNameError);
      return;
    }
    widget.onSubmit(
      CityRunConfiguration(
        cityName: name,
        startingPressure: _startingPressure,
        mainConcerns: List<CityConcern>.unmodifiable(_mainConcerns),
        candidateField: _candidateField,
        assistanceMode: _assistanceMode,
        campaignNoise: _campaignNoise,
        investigationTime: _investigationTime,
      ),
    );
  }

  IconData _pressureIcon(StartingPressure value) => switch (value) {
    StartingPressure.stable => Icons.sentiment_satisfied_alt_rounded,
    StartingPressure.strained => Icons.warning_amber_rounded,
    StartingPressure.crisis => Icons.crisis_alert_rounded,
  };
}

class _SetupIntro extends StatelessWidget {
  const _SetupIntro();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
    decoration: BoxDecoration(
      color: const Color(0xEFFFF7E2),
      border: Border.all(color: const Color(0xFF594127), width: 2),
      borderRadius: BorderRadius.circular(4),
      boxShadow: const [
        BoxShadow(color: Color(0x3D5E3C20), offset: Offset(3, 4)),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.assignment_outlined,
          color: ResiboColors.mutedRed,
          size: 31,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cityRegistrationForm.toUpperCase(),
                style: const TextStyle(
                  color: ResiboColors.navy,
                  fontFamily: 'LilitaOne',
                  fontSize: 20,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.l10n.cityRegistrationIntro,
                style: const TextStyle(
                  color: Color(0xFF43372B),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SetupSection extends StatelessWidget {
  const _SetupSection({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final int number;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
    decoration: BoxDecoration(
      color: const Color(0xDFFFF8E8),
      border: Border.all(color: const Color(0xFF725634), width: 2),
      borderRadius: BorderRadius.circular(5),
      boxShadow: const [
        BoxShadow(color: Color(0x2F5E3C20), offset: Offset(2, 3)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: ResiboColors.navy,
              foregroundColor: const Color(0xFFFFE2A1),
              child: Text(
                '$number',
                style: const TextStyle(fontFamily: 'LilitaOne', fontSize: 14),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: ResiboColors.navy,
                      fontFamily: 'LilitaOne',
                      fontSize: 17,
                      letterSpacing: .55,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF65533D),
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _ChoiceSection<T> extends StatelessWidget {
  const _ChoiceSection({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.descriptionOf,
    required this.iconOf,
    required this.keyOf,
    required this.onSelected,
  });

  final int number;
  final String title;
  final String subtitle;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final String Function(T) descriptionOf;
  final IconData Function(T) iconOf;
  final Key Function(T) keyOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => _SetupSection(
    number: number,
    title: title,
    subtitle: subtitle,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650
            ? values.length.clamp(1, 3)
            : constraints.maxWidth >= 440 && values.length == 2
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 9) / columns;
        return Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            for (final value in values)
              SizedBox(
                width: width,
                child: _ChoiceCard(
                  cardKey: keyOf(value),
                  label: labelOf(value),
                  description: descriptionOf(value),
                  icon: iconOf(value),
                  selected: value == selected,
                  onPressed: () => onSelected(value),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.cardKey,
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final Key cardKey;
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      key: cardKey,
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDCE9D4) : const Color(0xFFFFFCF1),
          border: Border.all(
            color: selected ? ResiboColors.teal : const Color(0xFF9B805B),
            width: selected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: selected
              ? const [
                  BoxShadow(color: Color(0x493E6D62), offset: Offset(2, 3)),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : icon,
              color: selected ? ResiboColors.teal : ResiboColors.navy,
              size: 23,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: ResiboColors.navy,
                      fontFamily: 'LilitaOne',
                      fontSize: 14,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF5E4E3B),
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ConcernChoice extends StatelessWidget {
  const _ConcernChoice({
    required this.concern,
    required this.selected,
    required this.onPressed,
  });

  final CityConcern concern;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => _ChoiceCard(
    cardKey: Key('city_concern_${concern.name}'),
    label: context.l10n.concernLabel(concern),
    description: context.l10n.concernDescription(concern),
    icon: _concernIcon(concern),
    selected: selected,
    onPressed: onPressed,
  );

  IconData _concernIcon(CityConcern value) => switch (value) {
    CityConcern.food => Icons.restaurant_outlined,
    CityConcern.poverty => Icons.family_restroom_outlined,
    CityConcern.health => Icons.local_hospital_outlined,
    CityConcern.education => Icons.school_outlined,
    CityConcern.water => Icons.water_drop_outlined,
    CityConcern.jobs => Icons.work_outline_rounded,
    CityConcern.cityServices => Icons.directions_bus_outlined,
    CityConcern.climate => Icons.flood_outlined,
  };
}

class _ConfigurationSummary extends StatelessWidget {
  const _ConfigurationSummary({
    required this.pressure,
    required this.concerns,
    required this.candidateField,
    required this.assistanceMode,
    required this.campaignNoise,
    required this.investigationTime,
  });

  final StartingPressure pressure;
  final Set<CityConcern> concerns;
  final CandidateField candidateField;
  final AssistanceMode assistanceMode;
  final CampaignNoise campaignNoise;
  final InvestigationTime investigationTime;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('city_configuration_summary'),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFEAD29A),
      border: Border.all(color: const Color(0xFF8A6B3D), width: 2),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map_rounded, color: ResiboColors.teal, size: 23),
            const SizedBox(width: 9),
            Text(
              context.l10n.cityFileSummary.toUpperCase(),
              style: const TextStyle(
                color: ResiboColors.navy,
                fontFamily: 'LilitaOne',
                fontSize: 15,
                letterSpacing: .5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.configurationSummaryLine(
            context.l10n.pressureLabel(pressure),
            context.l10n.candidateFieldLabel(candidateField),
            context.l10n.noiseLabel(campaignNoise),
          ),
          style: const TextStyle(
            color: ResiboColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          context.l10n.configurationConcerns(
            concerns.map(context.l10n.concernLabel).join(', '),
          ),
          style: const TextStyle(color: Color(0xFF67533A), fontSize: 12),
        ),
        Text(
          context.l10n.configurationModes(
            context.l10n.assistanceLabel(assistanceMode),
            context.l10n.investigationLabel(investigationTime),
          ),
          style: const TextStyle(color: Color(0xFF67533A), fontSize: 12),
        ),
      ],
    ),
  );
}
