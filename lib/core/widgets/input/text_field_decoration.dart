import 'package:code_base_riverpod/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TextFieldDecoration {
  static InputDecoration build({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    required Color borderColor,
    required ThemeData theme,
    bool filled = false,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1.2),
    );

    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: filled,
      fillColor: filled
          ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.2)
          : Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.hint),

      // Default outline border cho mọi trạng thái
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
      disabledBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.disabled, width: 1.2),
      ),
    );
  }
}
