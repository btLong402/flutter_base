import 'package:flutter/material.dart';

/// Simple data model used to feed the custom grid showcase.
///
/// Provides deterministic layout metadata (aspect ratio, masonry height,
/// feature flag) so each grid strategy can render meaningful variations
/// without relying on network assets.
class GridDemoItem {
  const GridDemoItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.aspectRatio,
    required this.masonryHeight,
    required this.isFeatured,
  });

  final int id;
  final String title;
  final String subtitle;
  final Color color;
  final double aspectRatio;
  final double masonryHeight;
  final bool isFeatured;
}
