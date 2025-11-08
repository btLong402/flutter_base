import 'package:code_base_riverpod/core/l10n/l10n_extensions.dart';
import 'package:code_base_riverpod/core/theme/app_colors.dart';
import 'package:code_base_riverpod/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'text_field_decoration.dart';

class AppTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autoFocus;
  final bool required;
  final int? maxLines;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const AppTextInput({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = enabled ? AppColors.border : AppColors.disabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(label!, style: theme.textTheme.labelMedium),
                if (required)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          focusNode: focusNode,
          style: theme.textTheme.bodyLarge,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onFieldSubmitted: onSubmitted,
          validator: (value) {
            if (required && value!.isEmpty) {
              return context.l10n.validation_required(
                label ?? context.l10n.field_default,
              );
            }
            return validator?.call(value);
          },
          decoration: TextFieldDecoration.build(
            hint: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            borderColor: borderColor,
            theme: theme,
          ),
        ),
      ],
    );
  }
}
