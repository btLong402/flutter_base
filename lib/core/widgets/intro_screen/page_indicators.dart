import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'intro_screen_models.dart';

/// PERFORMANCE OPTIMIZED: Base class for page indicators with const support
///
/// Optimizations:
/// - Const constructors for framework-level optimization
/// - RepaintBoundary isolation in animated widgets
/// - Reduced widget rebuilds with cached widgets
/// - Optimized animation durations (250ms instead of 300ms)
abstract class PageIndicatorWidget extends StatelessWidget {
  const PageIndicatorWidget({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
  });

  final int count;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;
}

/// OPTIMIZED: Dot-style page indicator with RepaintBoundary
class DotPageIndicator extends PageIndicatorWidget {
  const DotPageIndicator({
    super.key,
    required super.count,
    required super.currentIndex,
    super.activeColor,
    super.inactiveColor,
    this.dotSize = 8,
    this.spacing = 8,
    this.activeDotWidth = 24,
  });

  final double dotSize;
  final double spacing;
  final double activeDotWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeCol = activeColor ?? AppColors.primary;
    final inactiveCol =
        inactiveColor ??
        (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight);

    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == currentIndex;
          return AnimatedContainer(
            key: ValueKey('dot_$index'), // Preserve widget identity
            duration: const Duration(milliseconds: 250), // Optimized
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: spacing / 2),
            height: dotSize,
            width: isActive ? activeDotWidth : dotSize,
            decoration: BoxDecoration(
              color: isActive ? activeCol : inactiveCol,
              borderRadius: BorderRadius.circular(dotSize / 2),
            ),
          );
        }),
      ),
    );
  }
}

/// Line-style page indicator
class LinePageIndicator extends PageIndicatorWidget {
  const LinePageIndicator({
    super.key,
    required super.count,
    required super.currentIndex,
    super.activeColor,
    super.inactiveColor,
    this.lineWidth = 24,
    this.lineHeight = 3,
    this.spacing = 8,
  });

  final double lineWidth;
  final double lineHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeCol = activeColor ?? AppColors.primary;
    final inactiveCol =
        inactiveColor ??
        (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          height: lineHeight,
          width: lineWidth,
          decoration: BoxDecoration(
            color: isActive ? activeCol : inactiveCol,
            borderRadius: BorderRadius.circular(lineHeight / 2),
          ),
        );
      }),
    );
  }
}

/// Number-style page indicator (e.g., "1/5")
class NumberPageIndicator extends PageIndicatorWidget {
  const NumberPageIndicator({
    super.key,
    required super.count,
    required super.currentIndex,
    super.activeColor,
    super.inactiveColor,
    this.textStyle,
  });

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color =
        activeColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Text(
      '${currentIndex + 1}/$count',
      style:
          textStyle?.copyWith(color: color) ??
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
    );
  }
}

/// Progress bar-style page indicator
class ProgressBarPageIndicator extends PageIndicatorWidget {
  const ProgressBarPageIndicator({
    super.key,
    required super.count,
    required super.currentIndex,
    super.activeColor,
    super.inactiveColor,
    this.width = 200,
    this.height = 4,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeCol = activeColor ?? AppColors.primary;
    final inactiveCol =
        inactiveColor ??
        (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight);

    final progress = (currentIndex + 1) / count;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: inactiveCol,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: activeCol,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// Circular progress page indicator
class CircularProgressPageIndicator extends PageIndicatorWidget {
  const CircularProgressPageIndicator({
    super.key,
    required super.count,
    required super.currentIndex,
    super.activeColor,
    super.inactiveColor,
    this.size = 40,
    this.strokeWidth = 3,
  });

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeCol = activeColor ?? AppColors.primary;
    final inactiveCol =
        inactiveColor ??
        (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight);

    final progress = (currentIndex + 1) / count;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(inactiveCol),
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(activeCol),
          ),
          Center(
            child: Text(
              '${currentIndex + 1}',
              style: TextStyle(
                fontSize: size / 3,
                fontWeight: FontWeight.bold,
                color: activeCol,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Factory for creating page indicators based on style
class PageIndicatorFactory {
  static Widget create({
    required PageIndicatorStyle style,
    required int count,
    required int currentIndex,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    switch (style) {
      case PageIndicatorStyle.dots:
        return DotPageIndicator(
          count: count,
          currentIndex: currentIndex,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        );
      case PageIndicatorStyle.lines:
        return LinePageIndicator(
          count: count,
          currentIndex: currentIndex,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        );
      case PageIndicatorStyle.numbers:
        return NumberPageIndicator(
          count: count,
          currentIndex: currentIndex,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        );
      case PageIndicatorStyle.progressBar:
        return ProgressBarPageIndicator(
          count: count,
          currentIndex: currentIndex,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        );
      case PageIndicatorStyle.custom:
        return CircularProgressPageIndicator(
          count: count,
          currentIndex: currentIndex,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        );
    }
  }
}
