import 'package:flutter/material.dart';

import '../../../core/assets/visual_asset_catalog.dart';

class ProfileBannerSlot extends StatelessWidget {
  const ProfileBannerSlot({
    required this.assetKey,
    required this.semanticLabel,
    required this.color,
    super.key,
  });

  final String assetKey;
  final String semanticLabel;
  final Color color;

  @override
  Widget build(BuildContext context) => InformationMediaSlot(
    assetKey: assetKey,
    semanticLabel: semanticLabel,
    aspectRatio: 2.7,
    color: color,
    icon: Icons.location_city_rounded,
  );
}

class SocialMediaImageSlot extends StatelessWidget {
  const SocialMediaImageSlot({
    required this.assetKey,
    required this.semanticLabel,
    required this.aspectRatio,
    required this.color,
    super.key,
  });

  final String assetKey;
  final String semanticLabel;
  final double aspectRatio;
  final Color color;

  @override
  Widget build(BuildContext context) => InformationMediaSlot(
    assetKey: assetKey,
    semanticLabel: semanticLabel,
    aspectRatio: aspectRatio,
    color: color,
    icon: Icons.photo_camera_back_rounded,
  );
}

class NewsImageSlot extends StatelessWidget {
  const NewsImageSlot({
    required this.assetKey,
    required this.semanticLabel,
    required this.color,
    this.compact = false,
    super.key,
  });

  final String assetKey;
  final String semanticLabel;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) => InformationMediaSlot(
    assetKey: assetKey,
    semanticLabel: semanticLabel,
    aspectRatio: compact ? 4 / 3 : 16 / 9,
    color: color,
    icon: Icons.newspaper_rounded,
  );
}

class InformationMediaSlot extends StatelessWidget {
  const InformationMediaSlot({
    required this.assetKey,
    required this.semanticLabel,
    required this.aspectRatio,
    required this.color,
    required this.icon,
    super.key,
  });

  final String assetKey;
  final String semanticLabel;
  final double aspectRatio;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final assetPath = VisualAssetCatalog.information(assetKey);
    return Semantics(
      image: true,
      label: semanticLabel,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: SizedBox(
          key: Key('information_media_$assetKey'),
          child: assetPath == null
              ? _InformationMediaFallback(color: color, icon: icon)
              : Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) =>
                      _InformationMediaFallback(color: color, icon: icon),
                ),
        ),
      ),
    );
  }
}

class _InformationMediaFallback extends StatelessWidget {
  const _InformationMediaFallback({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, .25)!,
          color,
          Color.lerp(color, Colors.black, .25)!,
        ],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: -22,
          bottom: -28,
          child: Icon(icon, size: 170, color: const Color(0x22FFFFFF)),
        ),
        Center(
          child: Icon(
            icon,
            size: 54,
            color: const Color(0xFFFFF1D1),
            shadows: const [
              Shadow(color: Colors.black54, offset: Offset(2, 3)),
            ],
          ),
        ),
      ],
    ),
  );
}
