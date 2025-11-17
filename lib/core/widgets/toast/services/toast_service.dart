import 'package:flutter/material.dart';

import '../controller/toast_controller.dart';
import '../models/toast_config.dart';

/// Toast service providing static methods for easy access
///
/// **Usage:**
/// ```dart
/// // Show success toast
/// ToastService.success(context, 'File saved successfully!');
///
/// // Show error toast
/// ToastService.error(context, 'Failed to upload file');
///
/// // Custom toast
/// ToastService.show(
///   context,
///   ToastConfig(
///     message: 'Custom message',
///     type: ToastType.info,
///     duration: Duration(seconds: 5),
///   ),
/// );
/// ```
class ToastService {
  ToastService._();

  static final ToastController _controller = ToastController.instance;

  /// Show a custom toast
  static void show(BuildContext context, ToastConfig config) {
    _controller.show(context, config);
  }

  /// Show success toast
  static void success(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _controller.show(
      context,
      ToastConfig.success(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show error toast
  static void error(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _controller.show(
      context,
      ToastConfig.error(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show warning toast
  static void warning(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _controller.show(
      context,
      ToastConfig.warning(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show info toast
  static void info(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    _controller.show(
      context,
      ToastConfig.info(
        message,
        title: title,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Dismiss current toast
  static void dismiss() {
    _controller.dismiss();
  }

  /// Clear all queued toasts
  static void clearQueue() {
    _controller.clearQueue();
  }

  /// Check if toast is showing
  static bool get isShowing => _controller.isShowing;

  /// Get queue length
  static int get queueLength => _controller.queueLength;
}
