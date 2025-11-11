import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_inset.dart';

/// Animated onboarding step widget with icon and text
class OnboardingStepWidget extends StatefulWidget {
  const OnboardingStepWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.isActive = false,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isActive;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  State<OnboardingStepWidget> createState() => _OnboardingStepWidgetState();
}

class _OnboardingStepWidgetState extends State<OnboardingStepWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(OnboardingStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        widget.backgroundColor ??
        (isDark ? AppColors.cardDark : AppColors.cardLight);
    final iconCol = widget.iconColor ?? AppColors.primary;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(AppInset.large),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: iconCol.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppInset.large),
                      decoration: BoxDecoration(
                        color: iconCol.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, size: 48, color: iconCol),
                    ),
                    const SizedBox(height: AppInset.large),
                    Text(
                      widget.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppInset.medium),
                    Text(
                      widget.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color:
                            (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight)
                                .withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Vertical timeline step widget for onboarding
class TimelineStepWidget extends StatelessWidget {
  const TimelineStepWidget({
    super.key,
    required this.title,
    required this.description,
    required this.stepNumber,
    this.isCompleted = false,
    this.isActive = false,
    this.isLast = false,
    this.icon,
  });

  final String title;
  final String description;
  final int stepNumber;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color stepColor;
    if (isCompleted) {
      stepColor = AppColors.success;
    } else if (isActive) {
      stepColor = AppColors.primary;
    } else {
      stepColor = isDark
          ? AppColors.textDisabledDark
          : AppColors.textDisabledLight;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          Column(
            children: [
              // Circle with number or icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? stepColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: stepColor, width: 2),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : icon != null
                      ? Icon(
                          icon,
                          color: isActive ? Colors.white : stepColor,
                          size: 20,
                        )
                      : Text(
                          '$stepNumber',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isActive ? Colors.white : stepColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              // Vertical line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: stepColor.withOpacity(0.3),
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppInset.large),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppInset.extraLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? stepColor : null,
                    ),
                  ),
                  const SizedBox(height: AppInset.small),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Checklist item widget for onboarding tasks
class ChecklistItemWidget extends StatelessWidget {
  const ChecklistItemWidget({
    super.key,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.onTap,
    this.icon,
  });

  final String title;
  final String? description;
  final bool isCompleted;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppInset.large),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withOpacity(0.1)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.success
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : (isDark
                            ? AppColors.textDisabledDark
                            : AppColors.textDisabledLight),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),

            const SizedBox(width: AppInset.large),

            // Icon
            if (icon != null) ...[
              Icon(
                icon,
                color: isCompleted ? AppColors.success : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppInset.medium),
            ],

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: AppInset.small),
                    Text(
                      description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
