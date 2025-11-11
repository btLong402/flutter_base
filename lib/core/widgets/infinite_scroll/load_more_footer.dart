import 'package:flutter/material.dart';

/// Animated footer that visualizes load-more progress, empty states, and errors.
///
/// ### States & Transitions:
/// - **Loading**: Spinner + "Loading…" text
/// - **Error**: Error icon + "Retry" button
/// - **End**: Checkmark + custom end label
/// - **Hidden**: When hasMore=true and not loading
///
/// ### Performance:
/// - Uses `AnimatedSwitcher` for smooth state transitions (220ms)
/// - Keyed children prevent unnecessary rebuilds
/// - Minimal widget tree - only visible when needed
///
/// ### UX Considerations:
/// - Clear visual feedback for each state
/// - Tappable retry action on error
/// - Semantically accessible labels
/// - Consistent with Material Design patterns
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({
    super.key,
    required this.isLoading,
    required this.hasMore,
    this.error,
    this.onRetry,
    this.emptyLabel = 'No items yet',
    this.endLabel = 'You have reached the end',
  });

  final bool isLoading;
  final bool hasMore;
  final Object? error;
  final VoidCallback? onRetry;
  final String emptyLabel;
  final String endLabel;

  bool get _hasError => error != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget child;

    if (_hasError) {
      child = _buildError(theme);
    } else if (isLoading) {
      child = _buildLoading(theme);
    } else if (!hasMore) {
      child = _buildEnd(theme);
    } else {
      child = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: child,
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Row(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('Loading…', style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildError(ThemeData theme) {
    return Row(
      key: const ValueKey('error'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
        const SizedBox(width: 8),
        Text(
          'Retry',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }

  Widget _buildEnd(ThemeData theme) {
    return Row(
      key: const ValueKey('end'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Text(
          endLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
