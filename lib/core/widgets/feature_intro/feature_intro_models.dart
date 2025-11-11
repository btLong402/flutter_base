import 'package:flutter/material.dart';

/// Data model for a single feature intro item
class FeatureIntroData {
  const FeatureIntroData({
    required this.title,
    required this.description,
    required this.targetKey,
    this.icon,
    this.image,
    this.position = FeatureIntroPosition.bottom,
    this.shape = FeatureIntroShape.rectangle,
    this.backgroundColor,
    this.textColor,
    this.highlightColor,
    this.titleStyle,
    this.descriptionStyle,
    this.padding,
    this.margin,
    this.customWidget,
  });

  final String title;
  final String description;
  final GlobalKey targetKey;
  final IconData? icon;
  final String? image;
  final FeatureIntroPosition position;
  final FeatureIntroShape shape;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? highlightColor;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? customWidget;
}

/// Configuration for feature intro behavior
class FeatureIntroConfig {
  const FeatureIntroConfig({
    this.overlayColor = const Color(0xDD000000),
    this.pulseAnimation = true,
    this.pulseDuration = const Duration(milliseconds: 1500),
    this.showSkipButton = true,
    this.showNextButton = true,
    this.skipButtonText = 'Skip',
    this.nextButtonText = 'Next',
    this.doneButtonText = 'Got it',
    this.enableTapToDismiss = false,
    this.enableSwipeToDismiss = false,
    this.autoPlayDuration,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.highlightPadding = const EdgeInsets.all(8),
    this.tooltipBorderRadius = 12.0,
    this.showStepIndicator = true,
  });

  final Color overlayColor;
  final bool pulseAnimation;
  final Duration pulseDuration;
  final bool showSkipButton;
  final bool showNextButton;
  final String skipButtonText;
  final String nextButtonText;
  final String doneButtonText;
  final bool enableTapToDismiss;
  final bool enableSwipeToDismiss;
  final Duration? autoPlayDuration;
  final Duration transitionDuration;
  final EdgeInsetsGeometry highlightPadding;
  final double tooltipBorderRadius;
  final bool showStepIndicator;
}

/// Position of the tooltip relative to the highlighted widget
enum FeatureIntroPosition {
  top,
  bottom,
  left,
  right,
  center,
  auto, // Automatically choose based on available space
}

/// Shape of the highlight around the target widget
enum FeatureIntroShape { rectangle, circle, roundedRectangle, oval }

/// Animation types for feature intro transitions
enum FeatureIntroAnimation { fade, scale, slide, none }
