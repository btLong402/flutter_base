import 'package:flutter/material.dart';

import '../custom_image_widget/custom_image_widget.dart';
import 'media_viewer.dart';

/// Responsive grid used when the gallery is displayed in grid mode.
class GalleryThumbnailGrid extends StatelessWidget {
  const GalleryThumbnailGrid({
    super.key,
    required this.items,
    required this.onItemTap,
    this.crossAxisCount = 3,
    this.spacing = 4,
    this.padding = EdgeInsets.zero,
    this.childAspectRatio = 1,
  });

  final List<GalleryMediaItem> items;
  final ValueChanged<int> onItemTap;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final hero = item.heroTag;

        Widget thumb;
        if (item.thumbnailSource != null) {
          thumb = CustomImageWidget(
            source: item.thumbnailSource!,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 180),
            placeholder: const _ThumbnailPlaceholder(),
          );
        } else if (!item.isVideo && item.imageSource != null) {
          thumb = CustomImageWidget(
            source: item.imageSource!,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 180),
            placeholder: const _ThumbnailPlaceholder(),
          );
        } else {
          thumb = const _ThumbnailPlaceholder();
        }

        if (hero != null) {
          thumb = Hero(tag: hero, child: thumb);
        }

        if (item.isVideo) {
          thumb = Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: thumb),
              const Align(
                alignment: Alignment.center,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return GestureDetector(
          onTap: () => onItemTap(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.black12),
              child: thumb,
            ),
          ),
        );
      },
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFE0E0E0),
      child: Center(child: Icon(Icons.photo, color: Colors.black38)),
    );
  }
}
