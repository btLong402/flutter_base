import 'package:code_base_riverpod/core/l10n/l10n_extensions.dart';
import 'package:code_base_riverpod/core/utils/localized_validators.dart';
import 'package:code_base_riverpod/core/widgets/input/app_text_input.dart';
import 'package:flutter/material.dart';

enum TextFieldType {
  email,
  password,
  search,
  phoneNumber,
  number,
  multiline,
  text,
}

class AppTextInputVariant extends StatefulWidget {
  final TextFieldType type;
  final TextEditingController controller;
  final String? label;
  final bool enabled;
  final bool autoFocus;
  final bool required;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  const AppTextInputVariant({
    super.key,
    required this.type,
    required this.controller,
    this.label,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autoFocus = false,
    this.required = false,
  });

  @override
  State<AppTextInputVariant> createState() => _AppTextInputVariantState();
}

class _AppTextInputVariantState extends State<AppTextInputVariant> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final controller = widget.controller;

    switch (type) {
      case TextFieldType.email:
        return AppTextInput(
          label: widget.label ?? 'Email',
          hint: context.l10n.hint_email,
          controller: controller,
          autoFocus: widget.autoFocus,
          required: widget.required,
          enabled: widget.enabled,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          validator:
              widget.validator ??
              LocalizedValidators.email(context, isRequired: widget.required),
          onChanged: widget.onChanged,
        );

      case TextFieldType.password:
        return AppTextInput(
          label: widget.label ?? 'Password',
          hint: context.l10n.hint_password,
          controller: controller,
          autoFocus: widget.autoFocus,
          enabled: widget.enabled,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _obscureText,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          validator:
              widget.validator ??
              LocalizedValidators.password(context, isRequired: true),
          onChanged: widget.onChanged,
        );

      case TextFieldType.search:
        return AppTextInput(
          label: widget.label,
          hint: context.l10n.hint_search,
          controller: controller,
          keyboardType: TextInputType.text,
          prefixIcon: const Icon(Icons.search),
          onChanged: widget.onChanged,
          validator: widget.validator,
          onSubmitted: widget.onSubmitted,
        );

      case TextFieldType.phoneNumber:
        return AppTextInput(
          label: widget.label ?? 'Phone Number',
          hint: context.l10n.hint_phone,
          autoFocus: widget.autoFocus,
          enabled: widget.enabled,
          required: widget.required,
          controller: controller,
          keyboardType: TextInputType.phone,
          validator:
              widget.validator ??
              LocalizedValidators.phone(context, isRequired: widget.required),
        );

      case TextFieldType.multiline:
        return AppTextInput(
          label: widget.label,
          hint: 'Enter text',
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          validator: widget.validator,
        );
      case TextFieldType.number:
        return AppTextInput(
          label: widget.label ?? 'Number',
          hint: 'Enter number',
          controller: controller,
          keyboardType: TextInputType.number,
          validator: widget.validator,
        );

      case TextFieldType.text:
        return AppTextInput(
          label: widget.label ?? 'Text',
          hint: 'Enter text',
          controller: controller,
          keyboardType: TextInputType.text,
          validator: widget.validator,
        );
    }
  }
}
