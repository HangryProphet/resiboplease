import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/candidate_portrait.dart';

enum CandidateFallbackStyle { silhouette, initials }

class CandidateImageSlot extends StatelessWidget {
  const CandidateImageSlot({
    required this.candidateId,
    required this.assetKey,
    required this.semanticLabel,
    required this.color,
    this.aspectRatio = 4 / 5,
    this.fit = BoxFit.cover,
    this.fallbackStyle = CandidateFallbackStyle.silhouette,
    this.borderRadius = 10,
    super.key,
  });

  final String candidateId;
  final String assetKey;
  final String semanticLabel;
  final Color color;
  final double aspectRatio;
  final BoxFit fit;
  final CandidateFallbackStyle fallbackStyle;
  final double borderRadius;

  static const _currentAssets = <String, String>{
    'candidate_maya_vargas_neutral':
        'assets/images/candidates/maya_vargas/maya_vargas_portrait.png',
    'candidate_julian_pratt_neutral':
        'assets/images/candidates/julian_pratt/julian_pratt_portrait.png',
    'candidate_victor_chen_neutral':
        'assets/images/candidates/victor_chen/victor_chen_portrait.png',
  };

  static String? assetPathFor(String assetKey) =>
      _currentAssets[assetKey] ?? candidatePortraitById(assetKey)?.assetPath;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: semanticLabel,
    child: AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF172536), width: 2),
          ),
          child: _assetOrFallback(),
        ),
      ),
    ),
  );

  Widget _assetOrFallback() {
    final path = assetPathFor(assetKey);
    if (path == null) return _fallback();
    return Image.asset(
      path,
      fit: fit,
      alignment: Alignment.topCenter,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() {
    final initials = candidateId
        .split('_')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, Colors.white, .28)!, color],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            fallbackStyle == CandidateFallbackStyle.silhouette
                ? Icons.person_rounded
                : Icons.badge_rounded,
            size: 62,
            color: Colors.white.withValues(alpha: .54),
          ),
          Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'LuckiestGuy',
              fontSize: 26,
              shadows: [Shadow(color: Colors.black54, offset: Offset(1, 2))],
            ),
          ),
          if (kDebugMode)
            const Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Text(
                'ART PENDING',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Circular candidate portrait without the rectangular frame used by dossier
/// art slots. This prevents square corners or a baked card surface from
/// showing inside CityBook avatars.
class CandidateAvatar extends StatelessWidget {
  const CandidateAvatar({
    required this.candidateId,
    required this.assetKey,
    required this.semanticLabel,
    required this.color,
    this.size = 48,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final String candidateId;
  final String assetKey;
  final String semanticLabel;
  final Color color;
  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final path = CandidateImageSlot.assetPathFor(assetKey);
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF3D2),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black45, offset: Offset(0, 2))],
        ),
        child: ClipOval(
          key: Key('candidate_avatar_$candidateId'),
          child: path == null
              ? _AvatarFallback(candidateId: candidateId, color: color)
              : Image.asset(
                  path,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  alignment: alignment,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) =>
                      _AvatarFallback(candidateId: candidateId, color: color),
                ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.candidateId, required this.color});

  final String candidateId;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(color, Colors.white, .28)!, color],
      ),
    ),
    child: Icon(Icons.person_rounded, color: Colors.white70, size: 30),
  );
}
