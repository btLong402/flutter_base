import 'package:code_base_riverpod/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


/// Toast helper for showing messages
class ToastHelper {
  static final FToast _fToast = FToast();

  /// Initialize toast (call this in the build method of your root widget)
  static void init(BuildContext context) {
    _fToast.init(context);
  }

  /// Show success toast
  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show error toast
  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show warning toast
  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show info toast
  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show custom toast
  static void showCustom(
    String message, {
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: backgroundColor ?? AppColors.primary,
      textColor: textColor ?? Colors.white,
      fontSize: fontSize ?? 16.0,
    );
  }

  /// Show custom widget toast
  static void showWidget(
    Widget widget, {
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    _fToast.showToast(child: widget, gravity: gravity, toastDuration: duration);
  }

  /// Remove all toasts
  static void removeAll() {
    _fToast.removeCustomToast();
    Fluttertoast.cancel();
  }
}

/// Custom toast widget
class CustomToastWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const CustomToastWidget({
    super.key,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
