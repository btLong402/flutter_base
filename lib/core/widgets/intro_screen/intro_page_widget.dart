import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_inset.dart';
import 'intro_screen_models.dart';

/// PERFORMANCE OPTIMIZED: Single page widget with precached images and efficient animations
///
/// Optimizations:
/// - StatefulWidget for image precaching in didChangeDependencies
/// - Cached Animation objects to avoid recreation on every build
/// - RepaintBoundary around visual content
/// - Const widgets where possible
/// - Optimized image cache dimensions
class IntroPageWidget extends StatefulWidget {
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
  State<IntroPageWidget> createState() => _IntroPageWidgetState();
}

class _IntroPageWidgetState extends State<IntroPageWidget> {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isImagePrecached = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // OPTIMIZATION: Precache images for instant display
    if (!_isImagePrecached && widget.data.image != null) {
      precacheImage(AssetImage(widget.data.image!), context);
      _isImagePrecached = true;
    }
  }

  @override
  void didUpdateWidget(IntroPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationController != widget.animationController) {
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    if (widget.animationController != null) {
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: widget.animationController!,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
        ),
      );

      _slideAnimation =
          Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(
              parent: widget.animationController!,
              curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        widget.data.backgroundColor ??
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
    final textColor =
        widget.data.textColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Container(
      color: backgroundColor,
      child: _buildLayout(context, textColor),
    );
  }

  Widget _buildLayout(BuildContext context, Color textColor) {
    switch (widget.layout) {
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
        if (widget.data.image != null)
          Image.asset(
            widget.data.image!,
            fit: BoxFit.cover,
            cacheHeight: 1200, // Optimized cache for background
            filterQuality: FilterQuality.medium,
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
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
    if (widget.data.customContent != null) {
      return widget.data.customContent!;
    }

    if (widget.data.imageWidget != null) {
      return widget.data.imageWidget!;
    }

    Widget visual;

    if (widget.data.icon != null) {
      visual = Icon(
        widget.data.icon,
        size: 120,
        color: widget.data.textColor ?? AppColors.primary,
      );
    } else if (widget.data.image != null) {
      // OPTIMIZATION: Cache image with explicit dimensions
      visual = Image.asset(
        widget.data.image!,
        height: widget.imageHeight ?? 250,
        width: fullWidth ? double.infinity : widget.imageWidth,
        fit: fullWidth ? BoxFit.cover : BoxFit.contain,
        cacheHeight: 500, // Optimized cache size
        filterQuality: FilterQuality.medium,
      );
    } else if (widget.data.lottieAsset != null) {
      // Placeholder for Lottie animation
      visual = Container(
        height: widget.imageHeight ?? 250,
        width: widget.imageWidth ?? 250,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.animation, size: 60, color: AppColors.primary),
        ),
      );
    } else {
      visual = const SizedBox.shrink();
    }

    // OPTIMIZATION: Use cached animations instead of creating new ones
    if (widget.showAnimation && widget.animationController != null) {
      return RepaintBoundary(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: visual),
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
        widget.data.titleStyle ??
        AppTextStyles.headlineMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        );

    final descriptionStyle =
        widget.data.descriptionStyle ??
        AppTextStyles.bodyLarge.copyWith(color: textColor.withValues(alpha: 0.8));

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          widget.data.title,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: titleStyle,
        ),
        const Gap(AppInset.large),
        Text(
          widget.data.description,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: descriptionStyle,
        ),
      ],
    );

    // OPTIMIZATION: Use cached animations
    if (widget.showAnimation && widget.animationController != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(position: _slideAnimation, child: content),
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
