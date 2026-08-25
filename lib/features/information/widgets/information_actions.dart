import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/audio/game_audio_service.dart';

/// Compact, tactile action used throughout the fictional information system.
///
/// It deliberately avoids Flutter's default button chrome so media links still
/// feel like part of the same chunky arcade interface as the rest of the game.
class InformationActionButton extends StatelessWidget {
  const InformationActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = const Color(0xFF304A61),
    this.expanded = false,
    this.buttonKey,
    this.sound = GameSound.uiTap,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool expanded;
  final Key? buttonKey;
  final GameSound? sound;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final base = disabled ? const Color(0xFF687078) : color;
    return Container(
      width: expanded ? double.infinity : null,
      decoration: BoxDecoration(
        color: const Color(0xFF07111D),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF0B121C), width: 2.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(base, Colors.white, .23)!,
                base,
                Color.lerp(base, Colors.black, .25)!,
              ],
              stops: const [0, .5, 1],
            ),
          ),
          child: InkWell(
            key: buttonKey,
            onTap: onPressed == null
                ? null
                : () {
                    if (sound case final effect?) {
                      GameAudioScope.maybeOf(context)?.play(effect);
                    }
                    onPressed!();
                  },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 39),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 17,
                        color: const Color(0xFFFFF1D1),
                        shadows: const [
                          Shadow(color: Colors.black54, offset: Offset(1, 1)),
                        ],
                      ),
                      const SizedBox(width: 7),
                    ],
                    Flexible(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFF1D1),
                          fontFamily: 'LilitaOne',
                          fontSize: 13,
                          height: 1,
                          letterSpacing: .45,
                          shadows: [
                            Shadow(color: Colors.black87, offset: Offset(1, 1)),
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

/// Pressable paper row for headlines and other information destinations.
class InformationLinkTile extends StatelessWidget {
  const InformationLinkTile({
    required this.title,
    required this.onPressed,
    required this.icon,
    this.eyebrow,
    this.subtitle,
    this.color = ResiboColors.navy,
    this.buttonKey,
    this.sound = GameSound.uiTap,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final Key? buttonKey;
  final GameSound? sound;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF07111D),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(color: Color(0x88000000), offset: Offset(0, 4)),
      ],
    ),
    padding: const EdgeInsets.only(bottom: 3),
    child: Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF101820), width: 2.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E5), Color(0xFFE8D8B5)],
          ),
        ),
        child: InkWell(
          key: buttonKey,
          onTap: () {
            if (sound case final effect?) {
              GameAudioScope.maybeOf(context)?.play(effect);
            }
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(color, Colors.white, .18)!,
                        Color.lerp(color, Colors.black, .18)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: const Color(0xFF101820),
                      width: 2,
                    ),
                  ),
                  child: Icon(icon, color: const Color(0xFFFFF1D1), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null) ...[
                        Text(
                          eyebrow!.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color.lerp(color, Colors.black, .22),
                            fontFamily: 'LilitaOne',
                            fontSize: 10,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF172332),
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF625746),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF172332),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
