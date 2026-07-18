import 'package:flutter/material.dart';

import '../../app/theme/resibo_theme.dart';
import '../../domain/models/city_indicator.dart';
import '../../l10n/l10n_extensions.dart';

class IndicatorCard extends StatelessWidget {
  const IndicatorCard({
    required this.indicator,
    required this.value,
    this.change,
    super.key,
  });

  final CityIndicator indicator;
  final int value;
  final int? change;

  @override
  Widget build(BuildContext context) {
    final state = context.l10n.indicatorStateLabel(value);
    final label = context.l10n.indicatorLabel(indicator);
    final isPressure = indicator == CityIndicator.corruptionPressure;
    final normalized = isPressure ? 1 - value / 100 : value / 100;
    final color = normalized < .4
        ? ResiboColors.mutedRed
        : normalized < .6
        ? ResiboColors.gold
        : ResiboColors.teal;
    return Semantics(
      label:
          '$label: $state${change == null ? '' : ', ${context.l10n.change} $change'}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (change case final amount?)
                    Text(
                      '${amount >= 0 ? '+' : ''}$amount',
                      style: TextStyle(
                        color: amount == 0
                            ? Colors.grey
                            : (isPressure ? amount < 0 : amount > 0)
                            ? ResiboColors.teal
                            : ResiboColors.mutedRed,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: normalized.clamp(0, 1),
                  color: color,
                  backgroundColor: color.withValues(alpha: .14),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
