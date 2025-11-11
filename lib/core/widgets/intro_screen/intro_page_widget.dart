import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_inset.dart';
import 'intro_screen_models.dart';

/// Single page widget for intro screen with customizable layout
class IntroPageWidget extends StatelessWidget {
  const IntroPageWidget({
    super.key,
    required this.data,
    this.animationController,
    this.layout = IntroPageLayout.standard,
    this.imageHeight,
    this.imageWidth,
    this.showAnimation = true,
  });

  final IntroPageData data;
  final AnimationController? animationController;
  final IntroPageLayout layout;
  final double? imageHeight;
  final double? imageWidth;
  final bool showAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        data.backgroundColor ??
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
    final textColor =
        data.textColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Container(
      color: backgroundColor,
      child: _buildLayout(context, textColor),
    );
  }

  Widget _buildLayout(BuildContext context, Color textColor) {
    switch (layout) {
      case IntroPageLayout.standard:
        return _buildStandardLayout(context, textColor);
      case IntroPageLayout.centered:
        return _buildCenteredLayout(context, textColor);
      case IntroPageLayout.imageTop:
        return _buildImageTopLayout(context, textColor);
      case IntroPageLayout.imageBackground:
        return _buildImageBackgroundLayout(context, textColor);
      case IntroPageLayout.split:
        return _buildSplitLayout(context, textColor);
      case IntroPageLayout.card:
        return _buildCardLayout(context, textColor);
    }
  }

  Widget _buildStandardLayout(BuildContext context, Color textColor) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppInset.extraLarge),
        child: Column(
          children: [
            const Spacer(),
            _buildVisual(context),
            const Spacer(),
            _buildTextContent(context, textColor),
            const Gap(AppInset.extraExtraLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredLayout(BuildContext context, Color textColor) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppInset.extraLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVisual(context),
              AppInset.gapExtraLarge,
              _buildTextContent(context, textColor, centered: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageTopLayout(BuildContext context, Color textColor) {
    return Column(
      children: [
        Expanded(flex: 3, child: _buildVisual(context, fullWidth: true)),
        Expanded(
          flex: 2,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppInset.extraLarge),
              child: _buildTextContent(context, textColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageBackgroundLayout(BuildContext context, Color textColor) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (data.image != null) Image.asset(data.image!, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppInset.extraLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTextContent(context, Colors.white),
                const Gap(AppInset.extraExtraLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitLayout(BuildContext context, Color textColor) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(child: _buildVisual(context, fullWidth: true)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppInset.extraLarge),
              child: _buildTextContent(context, textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLayout(BuildContext context, Color textColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppInset.extraLarge),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            child: Padding(
              padding: const EdgeInsets.all(AppInset.extraExtraLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildVisual(context),
                  AppInset.gapExtraLarge,
                  _buildTextContent(context, textColor, centered: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisual(BuildContext context, {bool fullWidth = false}) {
    if (data.customContent != null) {
      return data.customContent!;
    }

    if (data.imageWidget != null) {
      return data.imageWidget!;
    }

    Widget visual;

    if (data.icon != null) {
      visual = Icon(
        data.icon,
        size: 120,
        color: data.textColor ?? AppColors.primary,
      );
    } else if (data.image != null) {
      visual = Image.asset(
        data.image!,
        height: imageHeight ?? 250,
        width: fullWidth ? double.infinity : imageWidth,
        fit: fullWidth ? BoxFit.cover : BoxFit.contain,
      );
    } else if (data.lottieAsset != null) {
      // Placeholder for Lottie animation
      visual = Container(
        height: imageHeight ?? 250,
        width: imageWidth ?? 250,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.animation, size: 60, color: AppColors.primary),
        ),
      );
    } else {
      visual = const SizedBox.shrink();
    }

    if (showAnimation && animationController != null) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: animationController!,
            curve: const Interval(0, 0.6, curve: Curves.easeOut),
          ),
        ),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: animationController!,
                  curve: const Interval(0, 0.6, curve: Curves.easeOut),
                ),
              ),
          child: visual,
        ),
      );
    }

    return visual;
  }

  Widget _buildTextContent(
    BuildContext context,
    Color textColor, {
    bool centered = false,
  }) {
    final titleStyle =
        data.titleStyle ??
        AppTextStyles.headlineMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        );

    final descriptionStyle =
        data.descriptionStyle ??
        AppTextStyles.bodyLarge.copyWith(color: textColor.withOpacity(0.8));

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          data.title,
          style: titleStyle,
          textAlign: centered ? TextAlign.center : TextAlign.start,
        ),
        AppInset.gapLarge,
        Text(
          data.description,
          style: descriptionStyle,
          textAlign: centered ? TextAlign.center : TextAlign.start,
        ),
      ],
    );

    if (showAnimation && animationController != null) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: animationController!,
            curve: const Interval(0.4, 1, curve: Curves.easeOut),
          ),
        ),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: animationController!,
                  curve: const Interval(0.4, 1, curve: Curves.easeOut),
                ),
              ),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Available layout options for intro pages
enum IntroPageLayout {
  standard, // Visual at top, text at bottom
  centered, // All content centered
  imageTop, // Image takes top half
  imageBackground, // Image as background with overlay text
  split, // Split screen (visual left, text right)
  card, // Content in a card
}
