/// Enumerates the advanced grid layout strategies supported by the
/// `InfiniteScrollView` demos. Consolidated so benchmark and gallery screens
/// stay in sync when new layouts are introduced.
enum GridLayoutVariant {
  fixed,
  flexible,
  masonry,
  ratio,
  nested,
  asymmetric,
  autoPlacement,
}

extension GridLayoutVariantLabel on GridLayoutVariant {
  String get displayLabel {
    switch (this) {
      case GridLayoutVariant.fixed:
        return 'Fixed';
      case GridLayoutVariant.flexible:
        return 'Flexible';
      case GridLayoutVariant.masonry:
        return 'Masonry';
      case GridLayoutVariant.ratio:
        return 'Ratio';
      case GridLayoutVariant.nested:
        return 'Nested';
      case GridLayoutVariant.asymmetric:
        return 'Asymmetric';
      case GridLayoutVariant.autoPlacement:
        return 'Auto Placement';
    }
  }
}
