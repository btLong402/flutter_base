import 'package:flutter/material.dart';

/// Generic dropdown item model with support for icons, badges, and custom widgets
class DropdownItemData<T> {
  const DropdownItemData({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.trailing,
    this.leading,
    this.badge,
    this.isEnabled = true,
    this.customWidget,
    this.metadata,
  });

  /// The actual value of the item
  final T value;

  /// Display label for the item
  final String label;

  /// Optional subtitle text
  final String? subtitle;

  /// Optional leading icon
  final IconData? icon;

  /// Optional trailing widget
  final Widget? trailing;

  /// Optional custom leading widget (overrides icon)
  final Widget? leading;

  /// Optional badge text (e.g., "NEW", "PRO")
  final String? badge;

  /// Whether the item is enabled for selection
  final bool isEnabled;

  /// Optional custom widget (overrides label/subtitle)
  final Widget? customWidget;

  /// Optional metadata for custom use cases
  final Map<String, dynamic>? metadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItemData &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Configuration for dropdown appearance and behavior
class DropdownConfig {
  const DropdownConfig({
    this.maxHeight = 320,
    this.itemHeight = 56,
    this.elevation = 16,
    this.borderRadius = 18,
    this.animationDuration = const Duration(milliseconds: 280),
    this.showSearchBar = false,
    this.searchHint = 'Search...',
    this.backgroundColor,
    this.selectedItemColor,
    this.hoverColor,
    this.disabledColor,
    this.textStyle,
    this.subtitleStyle,
    this.enableVirtualization = true,
    this.overlayOffset = const Offset(0, 10),
    this.closeOnSelect = true,
    this.showDividers = false,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  /// Maximum height of the dropdown overlay
  final double maxHeight;

  /// Height of each item
  final double itemHeight;

  /// Shadow elevation
  final double elevation;

  /// Border radius for the dropdown
  final double borderRadius;

  /// Animation duration for open/close
  final Duration animationDuration;

  /// Show search bar at the top
  final bool showSearchBar;

  /// Search bar hint text
  final String searchHint;

  /// Background color of dropdown
  final Color? backgroundColor;

  /// Color for selected item
  final Color? selectedItemColor;

  /// Hover color for items
  final Color? hoverColor;

  /// Disabled item color
  final Color? disabledColor;

  /// Text style for items
  final TextStyle? textStyle;

  /// Subtitle text style
  final TextStyle? subtitleStyle;

  /// Enable list virtualization for large lists
  final bool enableVirtualization;

  /// Offset from the button
  final Offset overlayOffset;

  /// Close dropdown after selection
  final bool closeOnSelect;

  /// Show dividers between items
  final bool showDividers;

  /// Padding around the dropdown content
  final EdgeInsetsGeometry padding;

  /// Padding for each item
  final EdgeInsetsGeometry itemPadding;
}

/// Dropdown button style configuration
class DropdownButtonStyle {
  const DropdownButtonStyle({
    this.height = 56,
    this.borderRadius = 16,
    this.borderWidth = 1.5,
    this.borderColor,
    this.backgroundColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
    this.iconSize = 24,
    this.iconColor,
    this.textStyle,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.elevation = 3,
    this.shadowColor,
  });

  final double height;
  final double borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double elevation;
  final Color? shadowColor;
}

/// Enum for dropdown overlay position
enum DropdownPosition {
  /// Show below the button
  bottom,

  /// Show above the button
  top,

  /// Auto-detect based on available space
  auto,
}

/// Multi-select configuration
class MultiSelectConfig {
  const MultiSelectConfig({
    this.maxSelections,
    this.showCounter = true,
    this.showChips = false,
    this.chipMaxWidth = 120,
    this.selectAllOption = false,
    this.selectAllText = 'Select All',
    this.clearAllText = 'Clear All',
  });

  /// Maximum number of selections allowed
  final int? maxSelections;

  /// Show selection counter
  final bool showCounter;

  /// Show selected items as chips
  final bool showChips;

  /// Maximum width for each chip
  final double chipMaxWidth;

  /// Show "Select All" option
  final bool selectAllOption;

  /// Text for select all option
  final String selectAllText;

  /// Text for clear all option
  final String clearAllText;
}
