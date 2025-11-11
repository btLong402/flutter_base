import 'dart:math' as math;

import 'package:code_base_riverpod/core/widgets/custom_gallery_widget/media_viewer.dart';
import 'package:code_base_riverpod/core/widgets/custom_image_widget/image_loader.dart';
import 'package:flutter/material.dart';

import 'package:code_base_riverpod/features/infinity_scroll/presentation/screens/media_gallery_example.dart';

/// Simulated repository that produces paginated media tiles for custom grids.
class GridDemoRepository {
  const GridDemoRepository({this.seed = 48});

  final int seed;

  static const List<Color> _palettes = <Color>[
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

  static const List<String> _categories = <String>[
    'Inspiration',
    'Travel',
    'Architecture',
    'Food',
    'Lifestyle',
    'Productivity',
  ];

  Future<List<MediaItem>> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final random = math.Random(seed + page * 13);
    await Future<void>.delayed(
      Duration(milliseconds: 220 + random.nextInt(160)),
    );

    return List<MediaItem>.generate(pageSize, (index) {
      final globalIndex = (page - 1) * pageSize + index;
      final color = _palettes[globalIndex % _palettes.length];
      final category = _categories[globalIndex % _categories.length];
      final aspectRatio = 0.75 + random.nextDouble() * 0.9; // 0.75 - 1.65
      final masonryHeight = 140 + random.nextInt(140); // 140 - 280
      final isFeatured = globalIndex % 9 == 0;
      final isVideo = random.nextBool();

      return MediaItem(
        id: globalIndex,
        title: 'Idea ${globalIndex + 1}',
        isVideo: isVideo,
        previewUrl: 'https://picsum.photos/seed/grid$globalIndex/600/900',
        heroTag: 'grid-demo-$globalIndex',
        subtitle: category,
        color: color,
        aspectRatio: aspectRatio,
        masonryHeight: masonryHeight.toDouble(),
        isFeatured: isFeatured,
        mediaItem: GalleryMediaItem.image(
          imageSource: CustomImageSource.network(
            'https://picsum.photos/seed/media$globalIndex/1000/1500',
          ),
          heroTag: 'grid-demo-$globalIndex',
        ),
      );
    });
  }

  Future<void> prefetchThumbnails(List<MediaItem> items) async {
    // Emulate lightweight image cache warm-up for better perceived smoothness.
    if (items.isEmpty) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 18));
  }
}
