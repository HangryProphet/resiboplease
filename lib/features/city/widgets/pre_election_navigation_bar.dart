import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../l10n/l10n_extensions.dart';

enum PreElectionDestination { city, dossiers, chronicle }

class PreElectionNavigationBar extends StatelessWidget {
  const PreElectionNavigationBar({required this.current, super.key});

  final PreElectionDestination current;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF101E2E),
      border: Border(top: BorderSide(color: Color(0xFF060C13), width: 3)),
      boxShadow: [
        BoxShadow(
          color: Color(0xA8000000),
          offset: Offset(0, -4),
          blurRadius: 8,
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 5),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                key: const Key('pre_election_nav_city'),
                label: context.l10n.navCity,
                icon: Icons.location_city_rounded,
                selected: current == PreElectionDestination.city,
                onTap: () => context.go('/city'),
              ),
            ),
            Expanded(
              child: _NavItem(
                key: const Key('pre_election_nav_dossiers'),
                label: context.l10n.navDossiers,
                icon: Icons.folder_copy_rounded,
                selected: current == PreElectionDestination.dossiers,
                onTap: () => context.go('/candidates'),
              ),
            ),
            Expanded(
              child: _NavItem(
                key: const Key('pre_election_nav_chronicle'),
                label: context.l10n.navChronicle,
                icon: Icons.newspaper_rounded,
                selected: current == PreElectionDestination.chronicle,
                onTap: () => context.go('/city/chronicle'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: selected ? const Color(0xFF263C50) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? ResiboColors.gold : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: selected
                      ? const Color(0xFFFFDEA0)
                      : const Color(0xFFB7C6CE),
                ),
                const SizedBox(height: 3),
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFFFE9B8)
                        : const Color(0xFFB7C6CE),
                    fontFamily: 'LilitaOne',
                    fontSize: 12,
                    height: 1,
                    letterSpacing: .35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
