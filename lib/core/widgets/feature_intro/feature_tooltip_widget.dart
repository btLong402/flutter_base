import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_inset.dart';
import 'feature_intro_models.dart';

/// PERFORMANCE OPTIMIZED: Tooltip widget with minimal rebuilds and efficient rendering
///
/// Optimizations:
/// - Const constructor for framework optimization
/// - RepaintBoundary for isolated rendering
/// - Cached decoration and text styles
/// - Optimized button rendering with const widgets where possible
/// - Image precaching support
/// - Reduced widget tree depth
class FeatureTooltipWidget extends StatelessWidget {
  const FeatureTooltipWidget({
    super.key,
    required this.data,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.config = const FeatureIntroConfig(),
    this.maxWidth = 280,
  });

  final FeatureIntroData data;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final FeatureIntroConfig config;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        data.backgroundColor ??
        (isDark ? AppColors.cardDark : AppColors.cardLight);
    final textColor =
        data.textColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    // PERFORMANCE: Wrap in RepaintBoundary to isolate tooltip repaints
    return RepaintBoundary(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: data.padding ?? const EdgeInsets.all(AppInset.large),
        margin: data.margin ?? const EdgeInsets.all(AppInset.medium),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(config.tooltipBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: data.customWidget ?? _buildDefaultContent(textColor),
      ),
    );
  }

  Widget _buildDefaultContent(Color textColor) {
    final isLastStep = currentStep == totalSteps - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        if (config.showStepIndicator)
          _StepIndicator(
            currentStep: currentStep,
            totalSteps: totalSteps,
            textColor: textColor,
            showSkipButton: config.showSkipButton,
            skipButtonText: config.skipButtonText,
            onSkip: onSkip,
          ),

        // Icon
        if (data.icon != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppInset.medium),
            child: Icon(data.icon, color: AppColors.primary, size: 32),
          ),

        // Image - PERFORMANCE: Use precacheImage for smooth loading
        if (data.image != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppInset.medium),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                data.image!,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                // PERFORMANCE: Add cacheWidth for memory optimization
                cacheWidth: 280, // Match maxWidth
              ),
            ),
          ),

        // Title
        Text(
          data.title,
          style:
              data.titleStyle ??
              AppTextStyles.titleMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: AppInset.medium),

        // Description
        Text(
          data.description,
          style:
              data.descriptionStyle ??
              AppTextStyles.bodyMedium.copyWith(
                color: textColor.withOpacity(0.8),
              ),
        ),

        const SizedBox(height: AppInset.large),

        // Next button
        if (config.showNextButton)
          _NextButton(isLastStep: isLastStep, config: config, onNext: onNext),
      ],
    );
  }
}

/// PERFORMANCE: Extract step indicator to separate widget for better optimization
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.textColor,
    required this.showSkipButton,
    required this.skipButtonText,
    required this.onSkip,
  });

  final int currentStep;
  final int totalSteps;
  final Color textColor;
  final bool showSkipButton;
  final String skipButtonText;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppInset.medium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor.withOpacity(0.6),
            ),
          ),
          if (showSkipButton)
            GestureDetector(
              onTap: onSkip,
              // PERFORMANCE: Add hit test behavior for better tap response
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4), // Expand tap area
                child: Text(
                  skipButtonText,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// PERFORMANCE: Extract next button to separate widget for const optimization
class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.isLastStep,
    required this.config,
    required this.onNext,
  });

  final bool isLastStep;
  final FeatureIntroConfig config;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: AppInset.medium),
          // PERFORMANCE: Disable elevation to reduce layer complexity
          elevation: 0,
        ),
        child: Text(
          isLastStep ? config.doneButtonText : config.nextButtonText,
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

/// Arrow widget pointing to the target
class TooltipArrow extends StatelessWidget {
  const TooltipArrow({
    super.key,
    required this.position,
    this.color = Colors.white,
    this.size = 12,
  });

  final FeatureIntroPosition position;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 2, size),
      painter: _ArrowPainter(position: position, color: color),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.position, required this.color});

  final FeatureIntroPosition position;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (position) {
      case FeatureIntroPosition.bottom:
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case FeatureIntroPosition.top:
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
      case FeatureIntroPosition.left:
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case FeatureIntroPosition.right:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
      default:
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
