// Smart Livestock — Shared Brand Logo Widget
// Use this widget everywhere the brand logo appears.
// Never recreate the logo with Flutter shapes or icons.

import 'package:flutter/material.dart';

/// The single source-of-truth logo widget for the Smart Livestock platform.
///
/// Usage:
///   BrandLogo.large()   → Splash screen   (~130 px height)
///   BrandLogo.medium()  → Role selection  (~88 px height)
///   BrandLogo.small()   → AppBar / sidebar (~34 px height)
///
/// All sizes use BoxFit.contain and preserve the original aspect ratio.
class BrandLogo extends StatelessWidget {
  final double height;

  const BrandLogo({super.key, required this.height});

  /// Splash screen — prominent, centered, generous whitespace.
  const BrandLogo.large({super.key}) : height = 130;

  /// Role selection — visible but not oversized.
  const BrandLogo.medium({super.key}) : height = 88;

  /// AppBar / sidebar — compact, clearly recognisable.
  const BrandLogo.small({super.key}) : height = 34;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/brand_logo.png',
      height: height,
      fit: BoxFit.contain,
      // Maintain natural width ratio; never squash into a fixed square.
      filterQuality: FilterQuality.high,
    );
  }
}
