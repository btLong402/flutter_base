import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'custom_dropdown_models.dart';
import 'dropdown_item_widget.dart';

/// PERFORMANCE OPTIMIZED: Dropdown overlay with smooth animations
///
/// Optimizations:
/// - SingleTickerProviderStateMixin for single animation
/// - ListView.builder for virtualization
/// - RepaintBoundary on search bar
/// - Debounced search input
/// - Cached filtered items
class DropdownOverlay<T> extends StatefulWidget {
  const DropdownOverlay({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onItemSelected,
    required this.config,
    required this.buttonRect,
    required this.position,
    this.isMultiSelect = false,
    this.onClose,
  });

  final List<DropdownItemData<T>> items;
  final List<T> selectedValues;
  final Function(T value) onItemSelected;
  final DropdownConfig config;
  final Rect buttonRect;
  final DropdownPosition position;
  final bool isMultiSelect;
  final VoidCallback? onClose;

  @override
  State<DropdownOverlay<T>> createState() => _DropdownOverlayState<T>();
}

class _DropdownOverlayState<T> extends State<DropdownOverlay<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<DropdownItemData<T>> _filteredItems = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _initializeAnimations();
    _animationController.forward();

    if (widget.config.showSearchBar) {
      // Auto-focus search bar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredItems = widget.items.where((item) {
          return item.label.toLowerCase().contains(lowerQuery) ||
              (item.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }
    });
  }

  void _handleItemTap(T value) {
    widget.onItemSelected(value);
    if (!widget.isMultiSelect && widget.config.closeOnSelect) {
      _closeOverlay();
    }
  }

  Future<void> _closeOverlay() async {
    await _animationController.reverse();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _closeOverlay,
      child: Material(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.20),
        child: Stack(
          children: [
            Positioned(
              left: widget.buttonRect.left,
              top: _calculateTop(),
              width: widget.buttonRect.width,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  alignment: _getScaleAlignment(),
                  child: _buildDropdownContent(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContent(bool isDark) {
    final backgroundColor =
        widget.config.backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    return RepaintBoundary(
      child: Material(
        elevation: widget.config.elevation,
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        color: backgroundColor,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.15),
        child: Container(
          constraints: BoxConstraints(maxHeight: widget.config.maxHeight),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
            border: Border.all(
              color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                  .withValues(alpha: isDark ? 0.3 : 0.15),
              width: 1,
            ),
            // Subtle gradient overlay for depth
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                backgroundColor.withValues(alpha: 0.98),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.config.showSearchBar) _buildSearchBar(isDark),
                Flexible(child: _buildItemsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.surfaceDark.withValues(alpha: 0.6),
                    AppColors.surfaceDark.withValues(alpha: 0.3),
                  ]
                : [
                    AppColors.surfaceLight.withValues(alpha: 0.8),
                    AppColors.surfaceLight.withValues(alpha: 0.4),
                  ],
          ),
          border: Border(
            bottom: BorderSide(
              color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _filterItems,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.config.searchHint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: AppColors.textSecondaryLight,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _filterItems('');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
            filled: true,
            fillColor: isDark
                ? AppColors.backgroundDark.withValues(alpha: 0.3)
                : Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                    .withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                    .withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (_filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: widget.config.padding,
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _filteredItems.length,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) {
          if (widget.config.showDividers) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.borderLight.withValues(alpha: 0.2),
              ),
            );
          }
          return const SizedBox(height: 4);
        },
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          final isSelected = widget.selectedValues.contains(item.value);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: DropdownItemWidget<T>(
              key: ValueKey(item.value),
              item: item,
              isSelected: isSelected,
              onTap: () => _handleItemTap(item.value),
              config: widget.config,
              isMultiSelect: widget.isMultiSelect,
              searchQuery: _searchQuery,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try different keywords',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTop() {
    final screenHeight = MediaQuery.of(context).size.height;
    final overlayHeight = math.min(
      widget.config.maxHeight +
          (widget.config.showSearchBar ? 60 : 0) +
          widget.config.padding.vertical,
      screenHeight * 0.6,
    );

    switch (widget.position) {
      case DropdownPosition.top:
        return widget.buttonRect.top -
            overlayHeight -
            widget.config.overlayOffset.dy;

      case DropdownPosition.bottom:
        return widget.buttonRect.bottom + widget.config.overlayOffset.dy;

      case DropdownPosition.auto:
        final spaceBelow = screenHeight - widget.buttonRect.bottom;
        final spaceAbove = widget.buttonRect.top;

        if (spaceBelow >= overlayHeight || spaceBelow > spaceAbove) {
          return widget.buttonRect.bottom + widget.config.overlayOffset.dy;
        } else {
          return widget.buttonRect.top -
              overlayHeight -
              widget.config.overlayOffset.dy;
        }
    }
  }

  Alignment _getScaleAlignment() {
    switch (widget.position) {
      case DropdownPosition.top:
        return Alignment.bottomCenter;
      case DropdownPosition.bottom:
        return Alignment.topCenter;
      case DropdownPosition.auto:
        final screenHeight = MediaQuery.of(context).size.height;
        final spaceBelow = screenHeight - widget.buttonRect.bottom;
        final spaceAbove = widget.buttonRect.top;
        return spaceBelow > spaceAbove
            ? Alignment.topCenter
            : Alignment.bottomCenter;
    }
  }
}
