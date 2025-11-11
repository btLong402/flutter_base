import 'package:flutter/material.dart';
import 'feature_intro_models.dart';

/// Overlay painter that highlights the target widget
class FeatureHighlightPainter extends CustomPainter {
  FeatureHighlightPainter({
    required this.targetRect,
    required this.shape,
    required this.overlayColor,
    required this.highlightColor,
    required this.padding,
    this.pulseAnimation = 1.0,
  });

  final Rect targetRect;
  final FeatureIntroShape shape;
  final Color overlayColor;
  final Color highlightColor;
  final EdgeInsetsGeometry padding;
  final double pulseAnimation;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw overlay
    final overlayPaint = Paint()..color = overlayColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // Calculate highlight rect with padding
    final paddingValues = padding.resolve(TextDirection.ltr);
    final highlightRect = Rect.fromLTRB(
      targetRect.left - paddingValues.left,
      targetRect.top - paddingValues.top,
      targetRect.right + paddingValues.right,
      targetRect.bottom + paddingValues.bottom,
    );

    // Create hole in overlay for the target
    final holePaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    _drawShape(canvas, highlightRect, holePaint);

    // Draw highlight border with pulse animation
    final borderPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * pulseAnimation;

    _drawShape(canvas, highlightRect, borderPaint);
  }

  void _drawShape(Canvas canvas, Rect rect, Paint paint) {
    switch (shape) {
      case FeatureIntroShape.rectangle:
        canvas.drawRect(rect, paint);
        break;
      case FeatureIntroShape.circle:
        final center = rect.center;
        final radius =
            (rect.width > rect.height ? rect.width : rect.height) / 2;
        canvas.drawCircle(center, radius, paint);
        break;
      case FeatureIntroShape.roundedRectangle:
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
        canvas.drawRRect(rrect, paint);
        break;
      case FeatureIntroShape.oval:
        canvas.drawOval(rect, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant FeatureHighlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.pulseAnimation != pulseAnimation;
  }
}

/// Helper to calculate tooltip position
class TooltipPositionCalculator {
  static Offset calculate({
    required Rect targetRect,
    required Size tooltipSize,
    required Size screenSize,
    required FeatureIntroPosition position,
    double spacing = 16,
  }) {
    switch (position) {
      case FeatureIntroPosition.top:
        return _calculateTopPosition(
          targetRect,
          tooltipSize,
          screenSize,
          spacing,
        );
      case FeatureIntroPosition.bottom:
        return _calculateBottomPosition(
          targetRect,
          tooltipSize,
          screenSize,
          spacing,
        );
      case FeatureIntroPosition.left:
        return _calculateLeftPosition(
          targetRect,
          tooltipSize,
          screenSize,
          spacing,
        );
      case FeatureIntroPosition.right:
        return _calculateRightPosition(
          targetRect,
          tooltipSize,
          screenSize,
          spacing,
        );
      case FeatureIntroPosition.center:
        return _calculateCenterPosition(targetRect, tooltipSize, screenSize);
      case FeatureIntroPosition.auto:
        return _calculateAutoPosition(
          targetRect,
          tooltipSize,
          screenSize,
          spacing,
        );
    }
  }

  static Offset _calculateTopPosition(
    Rect targetRect,
    Size tooltipSize,
    Size screenSize,
    double spacing,
  ) {
    final x = (targetRect.left + targetRect.right - tooltipSize.width) / 2;
    final y = targetRect.top - tooltipSize.height - spacing;

    return Offset(
      x.clamp(spacing, screenSize.width - tooltipSize.width - spacing),
      y.clamp(spacing, screenSize.height - tooltipSize.height - spacing),
    );
  }

  static Offset _calculateBottomPosition(
    Rect targetRect,
    Size tooltipSize,
    Size screenSize,
    double spacing,
  ) {
    final x = (targetRect.left + targetRect.right - tooltipSize.width) / 2;
    final y = targetRect.bottom + spacing;

    return Offset(
      x.clamp(spacing, screenSize.width - tooltipSize.width - spacing),
      y.clamp(spacing, screenSize.height - tooltipSize.height - spacing),
    );
  }

  static Offset _calculateLeftPosition(
    Rect targetRect,
    Size tooltipSize,
    Size screenSize,
    double spacing,
  ) {
    final x = targetRect.left - tooltipSize.width - spacing;
    final y = (targetRect.top + targetRect.bottom - tooltipSize.height) / 2;

    return Offset(
      x.clamp(spacing, screenSize.width - tooltipSize.width - spacing),
      y.clamp(spacing, screenSize.height - tooltipSize.height - spacing),
    );
  }

  static Offset _calculateRightPosition(
    Rect targetRect,
    Size tooltipSize,
    Size screenSize,
    double spacing,
  ) {
    final x = targetRect.right + spacing;
    final y = (targetRect.top + targetRect.bottom - tooltipSize.height) / 2;

    return Offset(
      x.clamp(spacing, screenSize.width - tooltipSize.width - spacing),
      y.clamp(spacing, screenSize.height - tooltipSize.height - spacing),
    );
  }

  static Offset _calculateCenterPosition(
    Rect targetRect,
    Size tooltipSize,
    Size screenSize,
  ) {
    return Offset(
      (screenSize.width - tooltipSize.width) / 2,
      (screenSize.height - tooltipSize.height) / 2,
    );
  }

  static Offset _calculateAutoPosition(
    Rect targetRect,
    Size tooltipSize,
    Size screenSize,
    double spacing,
  ) {
    // Try bottom first
    final bottomY = targetRect.bottom + spacing;
    if (bottomY + tooltipSize.height + spacing < screenSize.height) {
      return _calculateBottomPosition(
        targetRect,
        tooltipSize,
        screenSize,
        spacing,
      );
    }

    // Try top
    final topY = targetRect.top - tooltipSize.height - spacing;
    if (topY > spacing) {
      return _calculateTopPosition(
        targetRect,
        tooltipSize,
        screenSize,
        spacing,
      );
    }

    // Try right
    final rightX = targetRect.right + spacing;
    if (rightX + tooltipSize.width + spacing < screenSize.width) {
      return _calculateRightPosition(
        targetRect,
        tooltipSize,
        screenSize,
        spacing,
      );
    }

    // Try left
    final leftX = targetRect.left - tooltipSize.width - spacing;
    if (leftX > spacing) {
      return _calculateLeftPosition(
        targetRect,
        tooltipSize,
        screenSize,
        spacing,
      );
    }

    // Default to center if nothing fits
    return _calculateCenterPosition(targetRect, tooltipSize, screenSize);
  }
}
