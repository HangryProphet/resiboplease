import 'package:flutter/material.dart';

class ContentShell extends StatelessWidget {
  const ContentShell({
    required this.child,
    this.maxWidth = 1080,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}
