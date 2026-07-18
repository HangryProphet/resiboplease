import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';

const dossierInk = Color(0xFF172332);
const dossierPaper = Color(0xFFF5E8C9);
const dossierPaperLight = Color(0xFFFFF7E3);
const dossierPaperDark = Color(0xFFD7C49C);

class InvestigationBackdrop extends StatelessWidget {
  const InvestigationBackdrop({
    required this.child,
    this.showCity = false,
    super.key,
  });

  final Widget child;
  final bool showCity;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF173249), Color(0xFF0B1725)],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (showCity)
          Opacity(
            opacity: .32,
            child: Image.asset(
              'assets/images/city/bayhaven_base.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x12000000), Color(0xEC08131F)],
              stops: [0, .72],
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

class InvestigationHeader extends StatelessWidget {
  const InvestigationHeader({
    required this.title,
    required this.onBack,
    this.trailing,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
    decoration: const BoxDecoration(
      color: Color(0xE616263B),
      border: Border(bottom: BorderSide(color: Color(0xFF070E17), width: 3)),
      boxShadow: [
        BoxShadow(
          color: Color(0x85000000),
          offset: Offset(0, 4),
          blurRadius: 8,
        ),
      ],
    ),
    child: Row(
      children: [
        GameIconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: Icons.arrow_back_rounded,
          onPressed: onBack,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Center(
            child: Transform.rotate(
              angle: -.015,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: dossierPaper,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: dossierInk, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0xB5000000), offset: Offset(2, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: dossierInk,
                        fontFamily: 'LuckiestGuy',
                        fontSize: 22,
                        height: 1,
                        letterSpacing: 1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF5A4C38),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 48, child: trailing),
      ],
    ),
  );
}

class GameIconButton extends StatelessWidget {
  const GameIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color = const Color(0xFF304A61),
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Container(
      width: 46,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF07111D),
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(color: Color(0xFFAEC0C7), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(icon, color: const Color(0xFFFFEFCB)),
        ),
      ),
    ),
  );
}

class PaperPanel extends StatelessWidget {
  const PaperPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = dossierPaperLight,
    this.borderRadius = 8,
    this.borderWidth = 2,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(color, Colors.white, .13)!, color],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: dossierInk, width: borderWidth),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          offset: Offset(3, 5),
          blurRadius: 2,
        ),
        BoxShadow(color: Color(0x26FFFFFF), offset: Offset(-1, -1)),
      ],
    ),
    child: child,
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.label, this.icon, this.color, super.key});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 20, color: color ?? ResiboColors.mutedRed),
        const SizedBox(width: 7),
      ],
      Expanded(
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color ?? dossierInk,
            fontFamily: 'LilitaOne',
            fontSize: 18,
            height: 1.05,
            letterSpacing: .45,
          ),
        ),
      ),
    ],
  );
}

class FileStamp extends StatelessWidget {
  const FileStamp({
    required this.label,
    this.color = ResiboColors.mutedRed,
    this.angle = -.05,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final double angle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontFamily: 'LilitaOne',
              fontSize: 13,
              height: 1,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    ),
  );
}

class ChunkyActionButton extends StatelessWidget {
  const ChunkyActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = ResiboColors.teal,
    this.compact = false,
    this.buttonKey,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool compact;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final base = disabled ? const Color(0xFF6B7076) : color;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080E16),
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(color: Color(0xB0000000), offset: Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(color: Color(0xFF0B121C), width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(base, Colors.white, .24)!,
                base,
                Color.lerp(base, Colors.black, .28)!,
              ],
              stops: const [0, .48, 1],
            ),
          ),
          child: InkWell(
            key: buttonKey,
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: compact ? 43 : 53),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 14 : 20,
                  vertical: compact ? 7 : 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: const Color(0xFFFFF1D1),
                        size: compact ? 19 : 23,
                        shadows: const [
                          Shadow(color: Colors.black54, offset: Offset(1, 2)),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFFFF1D1),
                          fontFamily: 'LilitaOne',
                          fontSize: compact ? 16 : 19,
                          height: 1,
                          letterSpacing: .55,
                          shadows: const [
                            Shadow(color: Colors.black87, offset: Offset(1, 2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DossierTabButton extends StatelessWidget {
  const DossierTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? dossierPaperLight : dossierPaperDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
      side: BorderSide(color: dossierInk, width: 2),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: dossierInk),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: dossierInk,
                fontFamily: 'LilitaOne',
                fontSize: 15,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class InvestigationPill extends StatelessWidget {
  const InvestigationPill({
    required this.label,
    required this.icon,
    this.color = ResiboColors.gold,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xE916263B),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: .8), width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFF1D1),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}
