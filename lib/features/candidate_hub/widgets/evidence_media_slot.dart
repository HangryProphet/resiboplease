import 'package:flutter/material.dart';

import '../../../core/assets/visual_asset_catalog.dart';
import '../../../domain/models/candidate_experience.dart';

class EvidenceMediaSlot extends StatelessWidget {
  const EvidenceMediaSlot({
    required this.media,
    required this.color,
    super.key,
  });

  final CandidateMedia media;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final assetPath = VisualAssetCatalog.evidence(media.assetKey);
    return Semantics(
      image: true,
      label: media.altText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: media.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: assetPath == null
                  ? _EvidenceMediaFallback(media: media, color: color)
                  : Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment(media.alignmentX, media.alignmentY),
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) =>
                          _EvidenceMediaFallback(media: media, color: color),
                    ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            media.caption,
            style: const TextStyle(
              color: Color(0xFF5E594F),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceMediaFallback extends StatelessWidget {
  const _EvidenceMediaFallback({required this.media, required this.color});

  final CandidateMedia media;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.lerp(color, Colors.white, .55)!,
          Color.lerp(color, const Color(0xFF132536), .42)!,
        ],
      ),
      border: Border.all(color: const Color(0xFF172536), width: 2),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _PlaceholderLines()),
        Center(
          child: Icon(
            switch (media.type) {
              CandidateMediaType.image => Icons.photo_camera_rounded,
              CandidateMediaType.document => Icons.description_rounded,
              CandidateMediaType.socialPost => Icons.forum_rounded,
              CandidateMediaType.videoStill => Icons.smart_display_rounded,
            },
            color: Colors.white.withValues(alpha: .86),
            size: 48,
          ),
        ),
      ],
    ),
  );
}

class _PlaceholderLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .14)
      ..strokeWidth = 8;
    for (var x = -size.height; x < size.width; x += 34) {
      canvas.drawLine(
        Offset(x.toDouble(), size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
