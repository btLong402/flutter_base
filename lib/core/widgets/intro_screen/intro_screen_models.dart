import 'package:flutter/material.dart';

/// Data model for a single intro page
class IntroPageData {
  const IntroPageData({
    required this.title,
    required this.description,
    this.image,
    this.icon,
    this.lottieAsset,
    this.backgroundColor,
    this.textColor,
    this.imageWidget,
    this.customContent,
    this.titleStyle,
    this.descriptionStyle,
  }) : assert(
         image != null ||
             icon != null ||
             lottieAsset != null ||
             imageWidget != null,
         'At least one visual element (image, icon, lottieAsset, or imageWidget) must be provided',
       );

  final String title;
  final String description;
  final String? image; // Asset path or URL
  final IconData? icon;
  final String? lottieAsset;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? imageWidget; // Custom widget for the visual
  final Widget? customContent; // Completely custom content
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
}

/// Configuration for intro screen behavior and appearance
class IntroScreenConfig {
  const IntroScreenConfig({
    this.showSkipButton = true,
    this.showBackButton = true,
    this.showNextButton = true,
    this.showDoneButton = true,
    this.skipButtonText = 'Skip',
    this.nextButtonText = 'Next',
    this.doneButtonText = 'Get Started',
    this.backButtonText = 'Back',
    this.showPageIndicator = true,
    this.pageIndicatorAlignment = Alignment.bottomCenter,
    this.pageIndicatorPadding = const EdgeInsets.only(bottom: 80),
    this.autoPlayDuration,
    this.enableSwipeGesture = true,
    this.pageTransitionDuration = const Duration(milliseconds: 350),
    this.pageTransitionCurve = Curves.easeInOut,
    this.buttonsAlignment = ButtonsAlignment.bottomSpaced,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 40,
    ),
  });

  final bool showSkipButton;
  final bool showBackButton;
  final bool showNextButton;
  final bool showDoneButton;
  final String skipButtonText;
  final String nextButtonText;
  final String doneButtonText;
  final String backButtonText;
  final bool showPageIndicator;
  final Alignment pageIndicatorAlignment;
  final EdgeInsetsGeometry pageIndicatorPadding;
  final Duration? autoPlayDuration;
  final bool enableSwipeGesture;
  final Duration pageTransitionDuration;
  final Curve pageTransitionCurve;
  final ButtonsAlignment buttonsAlignment;
  final EdgeInsetsGeometry contentPadding;
}

/// Enum for button alignment options
enum ButtonsAlignment {
  bottomSpaced, // Skip on left, Next/Done on right
  bottomCenter, // All buttons centered
  bottomRow, // All buttons in a row
  floatingTopRight, // Skip button floating top-right
}

/// Enum for page indicator styles
enum PageIndicatorStyle { dots, lines, numbers, progressBar, custom }

/// Enum for page transition types
enum IntroTransitionType { slide, fade, scale, rotation, depth, parallax }
