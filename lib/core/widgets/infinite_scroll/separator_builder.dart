import 'package:flutter/widgets.dart';

typedef InfiniteSeparatorBuilder =
    Widget Function(BuildContext context, int index);

/// Utility that maps logical list indices to physical children when separators
/// are present, similar to how [ListView.separated] works.
class SeparatorManager {
  const SeparatorManager({this.builder});

  final InfiniteSeparatorBuilder? builder;

  bool get hasSeparators => builder != null;

  /// Returns the total number of children once separators are interleaved.
  int childCount(int itemCount) {
    if (!hasSeparators || itemCount <= 1) {
      return itemCount;
    }
    return itemCount * 2 - 1;
  }

  /// Whether the given index corresponds to a separator.
  bool isSeparatorIndex(int index, int itemCount) {
    if (!hasSeparators || itemCount <= 1) {
      return false;
    }
    return index.isOdd;
  }

  /// Builds either an item or separator for the provided index.
  Widget buildChild({
    required BuildContext context,
    required int index,
    required int itemCount,
    required Widget Function(BuildContext context, int itemIndex) itemBuilder,
  }) {
    if (isSeparatorIndex(index, itemCount)) {
      final separatorIndex = index ~/ 2;
      return builder!.call(context, separatorIndex);
    }
    final itemIndex = itemIndexFor(index);
    return itemBuilder(context, itemIndex);
  }

  /// Maps a physical index back to the logical item index when separators exist.
  int itemIndexFor(int index) => hasSeparators ? index ~/ 2 : index;
}
