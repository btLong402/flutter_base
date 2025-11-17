import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'custom_dropdown_models.dart';
import 'dropdown_overlay.dart';

/// PERFORMANCE OPTIMIZED: Custom dropdown button with modern design
///
/// Features:
/// - Single and multi-select modes
/// - Search functionality
/// - Smooth animations
/// - Responsive layout
/// - Customizable styling
/// - Virtual scrolling for large lists
/// - Keyboard navigation support
///
/// Optimizations:
/// - StatefulWidget with minimal rebuilds
/// - RepaintBoundary on button
/// - Overlay entry for efficient rendering
/// - Cached computations
/// - ValueKey for item identity
class CustomDropdownButton<T> extends StatefulWidget {
  const CustomDropdownButton({
    super.key,
    required this.items,
    this.onChanged,
    this.selectedValue,
    this.selectedValues,
    this.hint = 'Select an option',
    this.label,
    this.errorText,
    this.helperText,
    this.isMultiSelect = false,
    this.config = const DropdownConfig(),
    this.buttonStyle = const DropdownButtonStyle(),
    this.position = DropdownPosition.auto,
    this.isEnabled = true,
    this.multiSelectConfig,
    this.onMultiSelectChanged,
  }) : assert(
         !isMultiSelect ||
             (selectedValues != null && onMultiSelectChanged != null),
         'Multi-select mode requires selectedValues and onMultiSelectChanged',
       ),
       assert(
         isMultiSelect || onChanged != null,
         'Single-select mode requires onChanged callback',
       );

  /// List of dropdown items
  final List<DropdownItemData<T>> items;

  /// Callback for single selection
  final ValueChanged<T?>? onChanged;

  /// Currently selected value (single-select)
  final T? selectedValue;

  /// Currently selected values (multi-select)
  final List<T>? selectedValues;

  /// Placeholder text
  final String hint;

  /// Optional label above the button
  final String? label;

  /// Error message
  final String? errorText;

  /// Helper text below the button
  final String? helperText;

  /// Enable multi-select mode
  final bool isMultiSelect;

  /// Dropdown configuration
  final DropdownConfig config;

  /// Button style configuration
  final DropdownButtonStyle buttonStyle;

  /// Overlay position preference
  final DropdownPosition position;

  /// Whether the dropdown is enabled
  final bool isEnabled;

  /// Multi-select configuration
  final MultiSelectConfig? multiSelectConfig;

  /// Callback for multi-select changes
  final ValueChanged<List<T>>? onMultiSelectChanged;

  @override
  State<CustomDropdownButton<T>> createState() =>
      _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {
  final GlobalKey _buttonKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _toggleDropdown() {
    if (!widget.isEnabled) return;

    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => DropdownOverlay<T>(
        items: widget.items,
        selectedValues: widget.isMultiSelect
            ? (widget.selectedValues ?? [])
            : (widget.selectedValue != null ? [widget.selectedValue as T] : []),
        onItemSelected: _handleItemSelected,
        config: widget.config,
        buttonRect: buttonRect,
        position: widget.position,
        isMultiSelect: widget.isMultiSelect,
        onClose: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _focusNode.requestFocus();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  void _handleItemSelected(T value) {
    if (widget.isMultiSelect) {
      final currentValues = List<T>.from(widget.selectedValues ?? []);
      if (currentValues.contains(value)) {
        currentValues.remove(value);
      } else {
        // Check max selections
        final maxSelections = widget.multiSelectConfig?.maxSelections;
        if (maxSelections == null || currentValues.length < maxSelections) {
          currentValues.add(value);
        }
      }
      widget.onMultiSelectChanged?.call(currentValues);
    } else {
      widget.onChanged?.call(value);
      _removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) _buildLabel(),
        RepaintBoundary(
          child: Focus(
            focusNode: _focusNode,
            child: GestureDetector(
              key: _buttonKey,
              onTap: _toggleDropdown,
              child: _buildButton(),
            ),
          ),
        ),
        if (widget.helperText != null || widget.errorText != null)
          _buildHelperText(),
      ],
    );
  }

  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        widget.label!,
        style: AppTextStyles.labelMedium.copyWith(
          color: widget.errorText != null
              ? AppColors.error
              : AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = _getBorderColor(isDark);
    final backgroundColor =
        widget.buttonStyle.backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      height: widget.buttonStyle.height,
      decoration: BoxDecoration(
        color: widget.isEnabled
            ? backgroundColor
            : backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(widget.buttonStyle.borderRadius),
        border: Border.all(
          color: borderColor,
          width: widget.buttonStyle.borderWidth,
        ),
        boxShadow: widget.buttonStyle.elevation > 0 || _isOpen
            ? [
                BoxShadow(
                  color:
                      (widget.buttonStyle.shadowColor ??
                              (_isFocused || _isOpen
                                  ? AppColors.primary
                                  : Colors.black))
                          .withValues(alpha:
                            _isOpen ? 0.18 : (_isFocused ? 0.12 : 0.08),
                          ),
                  blurRadius: _isOpen
                      ? 16
                      : (_isFocused ? 12 : widget.buttonStyle.elevation),
                  spreadRadius: _isOpen ? 2 : (_isFocused ? 1 : 0),
                  offset: Offset(
                    0,
                    _isOpen
                        ? 6
                        : (_isFocused ? 4 : widget.buttonStyle.elevation / 2),
                  ),
                ),
              ]
            : null,
      ),
      padding: widget.buttonStyle.padding,
      child: Row(
        children: [
          if (widget.buttonStyle.prefixIcon != null) ...[
            widget.buttonStyle.prefixIcon!,
            const SizedBox(width: 12),
          ],
          Expanded(child: _buildButtonContent()),
          const SizedBox(width: 8),
          _buildDropdownIcon(),
        ],
      ),
    );
  }

  Widget _buildButtonContent() {
    final textStyle = widget.buttonStyle.textStyle ?? AppTextStyles.bodyMedium;
    final hintStyle =
        widget.buttonStyle.hintStyle ??
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight);

    if (widget.isMultiSelect) {
      return _buildMultiSelectContent(textStyle, hintStyle);
    }

    return _buildSingleSelectContent(textStyle, hintStyle);
  }

  Widget _buildSingleSelectContent(TextStyle textStyle, TextStyle hintStyle) {
    if (widget.selectedValue == null) {
      return Text(widget.hint, style: hintStyle);
    }

    final selectedItem = widget.items.firstWhere(
      (item) => item.value == widget.selectedValue,
      orElse: () =>
          DropdownItemData(value: widget.selectedValue as T, label: ''),
    );

    return Row(
      children: [
        if (selectedItem.icon != null) ...[
          Icon(selectedItem.icon, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            selectedItem.label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectContent(TextStyle textStyle, TextStyle hintStyle) {
    final selectedCount = widget.selectedValues?.length ?? 0;

    if (selectedCount == 0) {
      return Text(widget.hint, style: hintStyle);
    }

    if (widget.multiSelectConfig?.showChips ?? false) {
      return _buildChips(textStyle);
    }

    return Text(
      '$selectedCount ${selectedCount == 1 ? 'item' : 'items'} selected',
      style: textStyle,
    );
  }

  Widget _buildChips(TextStyle textStyle) {
    final selectedItems = widget.items
        .where((item) => widget.selectedValues!.contains(item.value))
        .take(3)
        .toList();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...selectedItems.map(
          (item) => Container(
            constraints: BoxConstraints(
              maxWidth: widget.multiSelectConfig?.chipMaxWidth ?? 120,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              item.label,
              style: textStyle.copyWith(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (widget.selectedValues!.length > 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              '+${widget.selectedValues!.length - 3}',
              style: textStyle.copyWith(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownIcon() {
    return AnimatedRotation(
      duration: const Duration(milliseconds: 250),
      turns: _isOpen ? 0.5 : 0,
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: widget.buttonStyle.iconSize,
        color:
            widget.buttonStyle.iconColor ??
            (widget.isEnabled
                ? AppColors.textSecondaryLight
                : AppColors.textDisabledLight),
      ),
    );
  }

  Widget _buildHelperText() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12),
      child: Text(
        widget.errorText ?? widget.helperText!,
        style: AppTextStyles.bodySmall.copyWith(
          color: widget.errorText != null
              ? AppColors.error
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Color _getBorderColor(bool isDark) {
    if (widget.errorText != null) {
      return widget.buttonStyle.errorBorderColor ?? AppColors.error;
    }

    if (_isFocused || _isOpen) {
      return widget.buttonStyle.focusedBorderColor ?? AppColors.primary;
    }

    return widget.buttonStyle.borderColor ??
        (isDark ? AppColors.borderDark : AppColors.borderLight);
  }
}
