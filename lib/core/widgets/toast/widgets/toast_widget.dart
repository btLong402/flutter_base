import 'package:flutter/material.dart';

import '../models/toast_config.dart';
import '../models/toast_type.dart';

/// High-performance toast widget with smooth animations and swipe-to-dismiss
///
/// **Performance Optimizations:**
/// - Uses AnimatedBuilder with child parameter to prevent rebuilds
/// - RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - Hardware-accelerated transforms (GPU-accelerated)
/// - Efficient gesture detection with GestureDetector
/// - Optimized animation curves for 60 FPS
/// - Multi-directional swipe-to-dismiss (horizontal and vertical)
/// - Smooth fade, slide, and scale animations
///
/// **Features:**
/// - Swipe horizontally or vertically to dismiss
/// - Tap anywhere on toast to dismiss
/// - Automatic resistance when dragging beyond threshold
/// - Direction-aware dismiss animations
/// - Progress bar showing remaining time
/// - Responsive across all screen sizes
class ToastWidget extends StatefulWidget {
  const ToastWidget({
    super.key,
    required this.config,
    required this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 350),
  });

  final ToastConfig config;
  final VoidCallback onDismiss;
  final Duration animationDuration;

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  // Separate controller for rest animation to avoid ticker conflicts
  AnimationController? _restController;
  Animation<Offset>? _restAnimation;

  bool _isExiting = false;
  double _dragOffsetX = 0.0;
  double _dragOffsetY = 0.0;
  bool _isDragging = false;

  // Thresholds for swipe-to-dismiss
  static const double _dismissThresholdX = 100.0;
  static const double _dismissThresholdY = 80.0;
  static const double _maxDragExtent = 150.0;

  @override
  void initState() {
    super.initState();

    // Single controller for all animations
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Slide animation with smooth easing
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Fade animation with faster curve
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Scale animation for subtle zoom effect
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // Start entrance animation
    _controller.forward();

    // Auto-dismiss after duration
    if (widget.config.duration != Duration.zero) {
      Future.delayed(widget.config.duration + widget.animationDuration, () {
        if (mounted && !_isExiting) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _restController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isExiting) return;

    setState(() => _isExiting = true);
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.config.dismissible || _isExiting) return;
    setState(() => _isDragging = true);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.config.dismissible || _isExiting) return;

    setState(() {
      // Allow both horizontal and vertical swipes
      _dragOffsetX += details.delta.dx;
      _dragOffsetY += details.delta.dy;

      // Clamp drag offsets to max extent with resistance
      _dragOffsetX = _applyResistance(_dragOffsetX, _maxDragExtent);
      _dragOffsetY = _applyResistance(_dragOffsetY, _maxDragExtent);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.config.dismissible || _isExiting) return;

    final velocity = details.velocity.pixelsPerSecond;
    final shouldDismiss = _shouldDismissFromDrag(velocity);

    setState(() => _isDragging = false);

    if (shouldDismiss) {
      _dismissWithDirection();
    } else {
      // Animate back to original position
      _animateToRest();
    }
  }

  void _handlePanCancel() {
    if (!widget.config.dismissible || _isExiting) return;
    setState(() => _isDragging = false);
    _animateToRest();
  }

  /// Apply resistance to drag beyond threshold
  double _applyResistance(double offset, double maxExtent) {
    if (offset.abs() <= maxExtent) return offset;

    // Apply exponential resistance
    final excess = offset.abs() - maxExtent;
    final resistance = maxExtent + (excess * 0.3);
    return offset.sign * resistance;
  }

  /// Check if drag should trigger dismiss
  bool _shouldDismissFromDrag(Offset velocity) {
    // Check horizontal swipe
    if (_dragOffsetX.abs() >= _dismissThresholdX || velocity.dx.abs() > 500) {
      return true;
    }

    // Check vertical swipe
    if (_dragOffsetY.abs() >= _dismissThresholdY || velocity.dy.abs() > 500) {
      return true;
    }

    return false;
  }

  /// Dismiss with direction-based animation
  void _dismissWithDirection() {
    if (_isExiting) return; // Prevent duplicate dismiss calls

    setState(() => _isExiting = true);

    // Determine dismiss direction
    final isHorizontal = _dragOffsetX.abs() > _dragOffsetY.abs();

    // Animate to off-screen
    final targetX = isHorizontal ? _dragOffsetX.sign * 500 : _dragOffsetX;
    final targetY = !isHorizontal ? _dragOffsetY.sign * 500 : _dragOffsetY;

    // Smooth transition to target
    final begin = Offset(_dragOffsetX, _dragOffsetY);
    final end = Offset(targetX, targetY);

    final offsetTween = Tween<Offset>(begin: begin, end: end);
    final animation = offsetTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Listen to animation updates
    void listener() {
      if (mounted && !_controller.isDismissed) {
        setState(() {
          _dragOffsetX = animation.value.dx;
          _dragOffsetY = animation.value.dy;
        });
      }
    }

    animation.addListener(listener);

    // Ensure controller is in valid state before reversing
    if (_controller.status == AnimationStatus.completed ||
        _controller.status == AnimationStatus.forward) {
      _controller.reverse().then((_) {
        animation.removeListener(listener);
        if (mounted) {
          widget.onDismiss();
        }
      });
    } else {
      // Controller not in valid state, dismiss immediately
      animation.removeListener(listener);
      if (mounted) {
        widget.onDismiss();
      }
    }
  }

  /// Animate back to rest position
  void _animateToRest() {
    if (_isExiting) return; // Don't animate if already exiting

    // Clean up any existing rest animation
    _restController?.dispose();
    _restController = null;
    _restAnimation = null;

    final begin = Offset(_dragOffsetX, _dragOffsetY);
    const end = Offset.zero;

    final offsetTween = Tween<Offset>(begin: begin, end: end);
    _restController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _restAnimation = offsetTween.animate(
      CurvedAnimation(parent: _restController!, curve: Curves.easeOutCubic),
    );

    void listener() {
      if (mounted && !_isExiting && _restAnimation != null) {
        setState(() {
          _dragOffsetX = _restAnimation!.value.dx;
          _dragOffsetY = _restAnimation!.value.dy;
        });
      }
    }

    _restAnimation!.addListener(listener);

    _restController!.forward().then((_) {
      if (mounted && !_isExiting) {
        _restAnimation?.removeListener(listener);
        _restController?.dispose();
        _restController = null;
        _restAnimation = null;

        setState(() {
          _dragOffsetX = 0.0;
          _dragOffsetY = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    // PERFORMANCE: Calculate offset direction based on position
    final offsetDirection = config.position == ToastPosition.top ? -1.0 : 1.0;

    return Positioned.fill(
      child: Align(
        alignment: config.position.alignment,
        child: Padding(
          padding: config.position.edgeInsets(
            config.verticalOffset,
            config.horizontalPadding,
          ),
          child: GestureDetector(
            // PERFORMANCE: Enable swipe-to-dismiss with pan gestures
            onPanStart: widget.config.dismissible ? _handlePanStart : null,
            onPanUpdate: widget.config.dismissible ? _handlePanUpdate : null,
            onPanEnd: widget.config.dismissible ? _handlePanEnd : null,
            onPanCancel: widget.config.dismissible ? _handlePanCancel : null,
            // Tap to dismiss
            onTap: widget.config.dismissible
                ? () {
                    if (!_isExiting) _dismiss();
                  }
                : null,
            child: AnimatedBuilder(
              animation: _slideAnimation,
              // PERFORMANCE: Child parameter prevents rebuilding content
              child: _ToastContent(
                config: config,
                onDismiss: widget.config.dismissible ? _dismiss : null,
                onAction: config.action,
              ),
              builder: (context, child) {
                // Calculate slide offset based on animation progress
                final slideValue = _slideAnimation.value;
                final fadeValue = _fadeAnimation.value;
                final scaleValue = _scaleAnimation.value;

                // Entrance/exit animation offset
                final animationYOffset =
                    (1 - slideValue) * 100 * offsetDirection;

                // Combined offset with drag
                final totalOffsetX = _dragOffsetX * slideValue;
                final totalOffsetY =
                    animationYOffset + (_dragOffsetY * slideValue);

                // Calculate rotation based on horizontal drag
                final rotation = (_dragOffsetX / 500) * 0.05;

                // Apply slight scale down when dragging for visual feedback
                final dragScale = _isDragging ? 0.98 : 1.0;
                final finalScale = scaleValue * dragScale;

                // Calculate opacity with proper clamping to prevent invalid values
                // As user drags, opacity reduces based on drag distance
                final dragOpacityFactor = (1 - (_dragOffsetX.abs() / 300))
                    .clamp(0.0, 1.0);
                final finalOpacity = (fadeValue * dragOpacityFactor).clamp(
                  0.0,
                  1.0,
                );

                // PERFORMANCE: Use Transform for GPU-accelerated animations
                return Transform.translate(
                  offset: Offset(totalOffsetX, totalOffsetY),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: finalScale,
                      child: Opacity(opacity: finalOpacity, child: child),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Content of the toast (separated for performance)
/// PERFORMANCE: StatelessWidget with const constructor
class _ToastContent extends StatelessWidget {
  const _ToastContent({
    required this.config,
    required this.onDismiss,
    required this.onAction,
  });

  final ToastConfig config;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final type = config.type;
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          constraints: BoxConstraints(maxWidth: config.maxWidth, minHeight: 60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: type.color.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: type.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(type.icon, color: type.color, size: 24),
                      ),
                      const SizedBox(width: 12),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (config.title != null) ...[
                              Text(
                                config.title!,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              config.message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            if (config.actionLabel != null &&
                                onAction != null) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  onAction?.call();
                                  onDismiss?.call();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: type.color,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  config.actionLabel!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Close button
                      if (onDismiss != null)
                        IconButton(
                          onPressed: onDismiss,
                          icon: const Icon(Icons.close, size: 20),
                          color: Colors.grey[600],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Dismiss',
                        ),
                    ],
                  ),
                ),

                // Progress bar
                if (config.showProgressBar && config.duration != Duration.zero)
                  _ProgressBar(duration: config.duration, color: type.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated progress bar for toast duration
/// PERFORMANCE: Separate widget with own animation controller
class _ProgressBar extends StatefulWidget {
  const _ProgressBar({required this.duration, required this.color});

  final Duration duration;
  final Color color;

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: 1 - _controller.value,
            backgroundColor: widget.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          );
        },
      ),
    );
  }
}
