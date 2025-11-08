import 'package:flutter/material.dart';

import '../../domain/models/grid_demo_item.dart';

class GridDemoTile extends StatelessWidget {
  const GridDemoTile({super.key, required this.item, this.highlight = false});

  final GridDemoItem item;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color foreground = highlight
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;
    final Color background = highlight
        ? colorScheme.primary
        : colorScheme.primaryContainer;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: background.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Icon(
                  highlight
                      ? Icons.rocket_launch_rounded
                      : Icons.lightbulb_outline,
                  color: foreground.withOpacity(0.9),
                  size: highlight ? 36 : 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              style: textTheme.labelLarge?.copyWith(
                color: foreground.withOpacity(0.88),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
