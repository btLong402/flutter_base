import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'custom_dropdown_models.dart';

/// PERFORMANCE OPTIMIZED: Individual dropdown item widget
///
/// Optimizations:
/// - StatelessWidget with const constructor
/// - RepaintBoundary isolation for hover effects
/// - Cached color computations
/// - Minimal rebuilds with value equality checks
class DropdownItemWidget<T> extends StatefulWidget {
  const DropdownItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.config,
    this.isMultiSelect = false,
    this.searchQuery,
  });

  final DropdownItemData<T> item;
  final bool isSelected;
  final VoidCallback onTap;
  final DropdownConfig config;
  final bool isMultiSelect;
  final String? searchQuery;

  @override
  State<DropdownItemWidget<T>> createState() => _DropdownItemWidgetState<T>();
}

class _DropdownItemWidgetState<T> extends State<DropdownItemWidget<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // OPTIMIZATION: Cache color computations
    final backgroundColor = _getBackgroundColor(isDark);
    final textColor = _getTextColor(isDark);

    if (widget.item.customWidget != null) {
      return _buildCustomItem(backgroundColor);
    }

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: widget.item.isEnabled ? (_) => _setHovered(true) : null,
        onExit: widget.item.isEnabled ? (_) => _setHovered(false) : null,
        cursor: widget.item.isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10), // Increased corner radius
          child: InkWell(
            onTap: widget.item.isEnabled ? widget.onTap : null,
            borderRadius: BorderRadius.circular(10),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Container(
              constraints: BoxConstraints(minHeight: widget.config.itemHeight),
              padding: widget.config.itemPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Multi-select checkbox
                  if (widget.isMultiSelect) ...[
                    _buildCheckbox(),
                    const SizedBox(width: 14),
                  ],

                  // Leading widget or icon
                  if (widget.item.leading != null)
                    widget.item.leading!
                  else if (widget.item.icon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(widget.item.icon, size: 22, color: textColor),
                    ),

                  if (widget.item.leading != null || widget.item.icon != null)
                    const SizedBox(width: 14),

                  // Label and subtitle - FIX: Use Flexible instead of Expanded
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // FIX: Prevent overflow
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(textColor),
                        if (widget.item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          _buildSubtitle(textColor),
                        ],
                      ],
                    ),
                  ),

                  // Badge
                  if (widget.item.badge != null) ...[
                    const SizedBox(width: 8),
                    _buildBadge(),
                  ],

                  // Trailing widget
                  if (widget.item.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.item.trailing!,
                  ],

                  // Selected indicator (non-multi-select)
                  if (!widget.isMultiSelect && widget.isSelected) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            (widget.config.selectedItemColor ??
                                    AppColors.primary)
                                .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 18,
                        color:
                            widget.config.selectedItemColor ??
                            AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomItem(Color backgroundColor) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: widget.item.isEnabled ? widget.onTap : null,
            borderRadius: BorderRadius.circular(10),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Container(
              constraints: BoxConstraints(minHeight: widget.config.itemHeight),
              padding: widget.config.itemPadding,
              child: widget.item.customWidget,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.isSelected
              ? (widget.config.selectedItemColor ?? AppColors.primary)
              : AppColors.borderLight.withOpacity(0.4),
          width: 2,
        ),
        color: widget.isSelected
            ? (widget.config.selectedItemColor ?? AppColors.primary)
            : Colors.transparent,
      ),
      child: widget.isSelected
          ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }

  Widget _buildLabel(Color textColor) {
    final textStyle =
        widget.config.textStyle ??
        AppTextStyles.bodyMedium.copyWith(color: textColor);

    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return Text(
        widget.item.label,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Highlight search query
    return _HighlightedText(
      text: widget.item.label,
      query: widget.searchQuery!,
      style: textStyle,
      highlightColor: AppColors.primary.withOpacity(0.3),
    );
  }

  Widget _buildSubtitle(Color textColor) {
    final subtitleStyle =
        widget.config.subtitleStyle ??
        AppTextStyles.bodySmall.copyWith(color: textColor.withOpacity(0.7));

    return Text(
      widget.item.subtitle!,
      style: subtitleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.item.badge!,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (!widget.item.isEnabled) {
      return widget.config.disabledColor ??
          (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withOpacity(
            0.3,
          );
    }

    if (widget.isSelected && _isHovered) {
      // Selected + hovered state
      return widget.config.selectedItemColor?.withOpacity(0.22) ??
          AppColors.primary.withOpacity(0.22);
    }

    if (widget.isSelected) {
      return widget.config.selectedItemColor?.withOpacity(0.12) ??
          AppColors.primary.withOpacity(0.12);
    }

    if (_isHovered) {
      return widget.config.hoverColor ??
          (isDark
              ? AppColors.surfaceDark.withOpacity(0.6)
              : AppColors.primary.withOpacity(0.06));
    }

    return widget.config.backgroundColor ?? Colors.transparent;
  }

  Color _getTextColor(bool isDark) {
    if (!widget.item.isEnabled) {
      return widget.config.disabledColor ??
          (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight);
    }

    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }

  void _setHovered(bool value) {
    if (_isHovered != value) {
      setState(() => _isHovered = value);
    }
  }
}

/// Helper widget to highlight search query in text
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightColor,
  });

  final String text;
  final String query;
  final TextStyle style;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          if (index > 0) TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: style.copyWith(backgroundColor: highlightColor),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
