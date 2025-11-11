import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_inset.dart';

/// Spotlight widget that highlights a specific feature
class SpotlightWidget extends StatefulWidget {
  const SpotlightWidget({
    super.key,
    required this.child,
    required this.message,
    this.title,
    this.targetKey,
    this.spotlightColor = AppColors.primary,
    this.overlayColor = const Color(0xDD000000),
    this.onDismiss,
    this.showAnimation = true,
  });

  final Widget child;
  final String message;
  final String? title;
  final GlobalKey? targetKey;
  final Color spotlightColor;
  final Color overlayColor;
  final VoidCallback? onDismiss;
  final bool showAnimation;

  @override
  State<SpotlightWidget> createState() => _SpotlightWidgetState();
}

class _SpotlightWidgetState extends State<SpotlightWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.showAnimation) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showAnimation)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildSpotlight(),
          )
        else
          _buildSpotlight(),
      ],
    );
  }

  Widget _buildSpotlight() {
    return Material(
      color: widget.overlayColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppInset.extraLarge),
          child: Container(
            padding: const EdgeInsets.all(AppInset.extraLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.spotlightColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: widget.spotlightColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppInset.large),
                ],
                Text(
                  widget.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppInset.extraLarge),
                ElevatedButton(
                  onPressed: widget.onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.spotlightColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppInset.extraExtraLarge,
                      vertical: AppInset.large,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Got it!',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tooltip bubble widget for contextual hints
class TooltipBubbleWidget extends StatelessWidget {
  const TooltipBubbleWidget({
    super.key,
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.arrowPosition = TooltipArrowPosition.bottom,
    this.maxWidth = 200,
  });

  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final TooltipArrowPosition arrowPosition;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    final txtColor =
        textColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (arrowPosition == TooltipArrowPosition.top) _buildArrow(bgColor),
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(
            horizontal: AppInset.large,
            vertical: AppInset.medium,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: txtColor),
            textAlign: TextAlign.center,
          ),
        ),
        if (arrowPosition == TooltipArrowPosition.bottom) _buildArrow(bgColor),
      ],
    );
  }

  Widget _buildArrow(Color color) {
    return CustomPaint(
      size: const Size(12, 6),
      painter: _TooltipArrowPainter(
        color: color,
        isTop: arrowPosition == TooltipArrowPosition.top,
      ),
    );
  }
}

enum TooltipArrowPosition { top, bottom }

class _TooltipArrowPainter extends CustomPainter {
  _TooltipArrowPainter({required this.color, required this.isTop});

  final Color color;
  final bool isTop;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isTop) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Badge widget for "New" or "Updated" features
class FeatureBadgeWidget extends StatelessWidget {
  const FeatureBadgeWidget({
    super.key,
    required this.child,
    this.badgeText = 'New',
    this.badgeColor = AppColors.error,
    this.showBadge = true,
    this.position = BadgePosition.topRight,
  });

  final Widget child;
  final String badgeText;
  final Color badgeColor;
  final bool showBadge;
  final BadgePosition position;

  @override
  Widget build(BuildContext context) {
    if (!showBadge) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top:
              position == BadgePosition.topLeft ||
                  position == BadgePosition.topRight
              ? -8
              : null,
          bottom:
              position == BadgePosition.bottomLeft ||
                  position == BadgePosition.bottomRight
              ? -8
              : null,
          left:
              position == BadgePosition.topLeft ||
                  position == BadgePosition.bottomLeft
              ? -8
              : null,
          right:
              position == BadgePosition.topRight ||
                  position == BadgePosition.bottomRight
              ? -8
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum BadgePosition { topLeft, topRight, bottomLeft, bottomRight }
