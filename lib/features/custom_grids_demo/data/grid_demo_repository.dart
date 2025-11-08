import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/models/grid_demo_item.dart';

class GridDemoRepository {
  GridDemoRepository._();

  static final List<GridDemoItem> items = _generateItems();

  static List<GridDemoItem> _generateItems() {
    const palettes = <Color>[
      Color(0xFF264653),
      Color(0xFF2A9D8F),
      Color(0xFFE9C46A),
      Color(0xFFF4A261),
      Color(0xFFE76F51),
      Color(0xFF6D597A),
      Color(0xFFB56576),
      Color(0xFFE56B6F),
      Color(0xFFEAAC8B),
    ];

    const categories = <String>[
      'Inspiration',
      'Travel',
      'Architecture',
      'Food',
      'Lifestyle',
      'Productivity',
    ];

    final random = math.Random(24);
    return List<GridDemoItem>.generate(60, (index) {
      final color = palettes[index % palettes.length];
      final aspectRatio = 0.75 + random.nextDouble() * 0.9; // 0.75 - 1.65
      final masonryHeight = 140 + random.nextInt(120); // 140 - 260
      final isFeatured = index % 9 == 0;
      final category = categories[index % categories.length];
      return GridDemoItem(
        id: index,
        title: 'Idea ${index + 1}',
        subtitle: category,
        color: color,
        aspectRatio: aspectRatio,
        masonryHeight: masonryHeight.toDouble(),
        isFeatured: isFeatured,
      );
    });
  }
}
