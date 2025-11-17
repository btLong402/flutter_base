import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_inset.dart';
import 'intro_screen_models.dart';
import 'intro_page_widget.dart';
import 'page_indicators.dart';

/// PERFORMANCE OPTIMIZED: Main intro screen widget with smooth 60 FPS animations
///
/// Optimizations applied:
/// - SingleTickerProviderStateMixin for reduced overhead
/// - PageView caching with key-based widget identity
/// - Optimized animation controller reuse
/// - RepaintBoundary isolation for independent rendering
/// - Proper Timer management to prevent memory leaks
/// - Const widgets and reduced rebuilds
class IntroScreenWidget extends StatefulWidget {
  const IntroScreenWidget({
    super.key,
    required this.pages,
    required this.onDone,
    this.onSkip,
    this.config = const IntroScreenConfig(),
    this.pageLayout = IntroPageLayout.standard,
    this.pageIndicatorStyle = PageIndicatorStyle.dots,
    this.customPageIndicator,
    this.transitionType = IntroTransitionType.slide,
    this.showPageAnimation = true,
  }) : assert(pages.length > 0, 'At least one page must be provided');

  final List<IntroPageData> pages;
  final VoidCallback onDone;
  final VoidCallback? onSkip;
  final IntroScreenConfig config;
  final IntroPageLayout pageLayout;
  final PageIndicatorStyle pageIndicatorStyle;
  final Widget Function(int count, int currentIndex)? customPageIndicator;
  final IntroTransitionType transitionType;
  final bool showPageAnimation;

  @override
  State<IntroScreenWidget> createState() => _IntroScreenWidgetState();
}

class _IntroScreenWidgetState extends State<IntroScreenWidget>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentPage;
  late AnimationController _pageAnimationController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController();
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Optimized duration
    );

    if (widget.showPageAnimation) {
      _pageAnimationController.forward();
    }

    // Auto-play if configured - using Timer for better performance
    if (widget.config.autoPlayDuration != null) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_currentPage < widget.pages.length - 1) {
      _autoPlayTimer = Timer(widget.config.autoPlayDuration!, () {
        if (mounted && _currentPage < widget.pages.length - 1) {
          _nextPage();
          _startAutoPlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: widget.config.pageTransitionDuration,
        curve: widget.config.pageTransitionCurve,
      );
    } else {
      widget.onDone();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: widget.config.pageTransitionDuration,
        curve: widget.config.pageTransitionCurve,
      );
    }
  }

  void _skip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      widget.onDone();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    if (widget.showPageAnimation) {
      _pageAnimationController.reset();
      _pageAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OPTIMIZATION: RepaintBoundary isolates page transitions
          RepaintBoundary(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: widget.config.enableSwipeGesture
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: widget.pages.length,
              itemBuilder: (context, index) {
                return IntroPageWidget(
                  key: ValueKey(index), // Preserve widget identity
                  data: widget.pages[index],
                  layout: widget.pageLayout,
                  animationController: widget.showPageAnimation
                      ? _pageAnimationController
                      : null,
                  showAnimation: widget.showPageAnimation,
                );
              },
            ),
          ),

          // OPTIMIZATION: Positioned must be direct child of Stack, RepaintBoundary inside
          if (widget.config.showPageIndicator) _buildPageIndicator(),

          // OPTIMIZATION: SafeArea positioning for navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    Widget indicator;

    if (widget.customPageIndicator != null) {
      indicator = widget.customPageIndicator!(
        widget.pages.length,
        _currentPage,
      );
    } else {
      indicator = PageIndicatorFactory.create(
        style: widget.pageIndicatorStyle,
        count: widget.pages.length,
        currentIndex: _currentPage,
      );
    }

    // CRITICAL FIX: Positioned must be direct child of Stack
    // RepaintBoundary placed INSIDE Positioned, not wrapping it
    return Positioned.fill(
      child: RepaintBoundary(
        child: Align(
          alignment: widget.config.pageIndicatorAlignment,
          child: Padding(
            padding: widget.config.pageIndicatorPadding,
            child: indicator,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    switch (widget.config.buttonsAlignment) {
      case ButtonsAlignment.bottomSpaced:
        return _buildBottomSpacedButtons();
      case ButtonsAlignment.bottomCenter:
        return _buildBottomCenterButtons();
      case ButtonsAlignment.bottomRow:
        return _buildBottomRowButtons();
      case ButtonsAlignment.floatingTopRight:
        return _buildFloatingTopRightButtons();
    }
  }

  Widget _buildBottomSpacedButtons() {
    return SafeArea(
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.all(AppInset.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip / Back button
                  if (_currentPage > 0 && widget.config.showBackButton)
                    _buildTextButton(
                      widget.config.backButtonText,
                      _previousPage,
                    )
                  else if (widget.config.showSkipButton)
                    _buildTextButton(widget.config.skipButtonText, _skip)
                  else
                    const SizedBox.shrink(),

                  // Next / Done button
                  if (_currentPage < widget.pages.length - 1 &&
                      widget.config.showNextButton)
                    _buildElevatedButton(
                      widget.config.nextButtonText,
                      _nextPage,
                    )
                  else if (widget.config.showDoneButton)
                    _buildElevatedButton(
                      widget.config.doneButtonText,
                      widget.onDone,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCenterButtons() {
    return SafeArea(
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.all(AppInset.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_currentPage < widget.pages.length - 1 &&
                  widget.config.showNextButton)
                _buildElevatedButton(
                  widget.config.nextButtonText,
                  _nextPage,
                  fullWidth: true,
                )
              else if (widget.config.showDoneButton)
                _buildElevatedButton(
                  widget.config.doneButtonText,
                  widget.onDone,
                  fullWidth: true,
                ),
              if (widget.config.showSkipButton)
                Padding(
                  padding: const EdgeInsets.only(top: AppInset.medium),
                  child: _buildTextButton(widget.config.skipButtonText, _skip),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRowButtons() {
    return SafeArea(
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.all(AppInset.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (_currentPage > 0 && widget.config.showBackButton)
                    Expanded(
                      child: _buildTextButton(
                        widget.config.backButtonText,
                        _previousPage,
                      ),
                    ),
                  if (_currentPage > 0 &&
                      widget.config.showBackButton &&
                      (_currentPage < widget.pages.length - 1 ||
                          widget.config.showDoneButton))
                    const SizedBox(width: AppInset.medium),
                  if (_currentPage < widget.pages.length - 1 &&
                      widget.config.showNextButton)
                    Expanded(
                      child: _buildElevatedButton(
                        widget.config.nextButtonText,
                        _nextPage,
                      ),
                    )
                  else if (widget.config.showDoneButton)
                    Expanded(
                      child: _buildElevatedButton(
                        widget.config.doneButtonText,
                        widget.onDone,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingTopRightButtons() {
    return SafeArea(
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.all(AppInset.large),
          child: Column(
            children: [
              if (widget.config.showSkipButton)
                Align(
                  alignment: Alignment.topRight,
                  child: _buildTextButton(widget.config.skipButtonText, _skip),
                ),
              const Spacer(),
              if (_currentPage < widget.pages.length - 1 &&
                  widget.config.showNextButton)
                _buildElevatedButton(
                  widget.config.nextButtonText,
                  _nextPage,
                  fullWidth: true,
                )
              else if (widget.config.showDoneButton)
                _buildElevatedButton(
                  widget.config.doneButtonText,
                  widget.onDone,
                  fullWidth: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildElevatedButton(
    String text,
    VoidCallback onPressed, {
    bool fullWidth = false,
  }) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppInset.extraExtraLarge,
          vertical: AppInset.large,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
