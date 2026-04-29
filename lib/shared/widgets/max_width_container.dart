import 'package:flutter/material.dart';

/// A responsive wrapper that keeps content centered and prevents it from
/// stretching beyond a maximum width on medium and large screens.
///
/// By default the content will never exceed `1366` pixels, leaving the
/// remaining horizontal space empty on wider layouts.
class MaxWidthContainer extends StatelessWidget {
  const MaxWidthContainer({
    super.key,
    this.maxWidth = 1366,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    required this.child,
  });

  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
