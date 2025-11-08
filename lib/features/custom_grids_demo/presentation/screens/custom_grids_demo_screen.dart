import 'package:code_base_riverpod/core/widgets/grid/grid.dart';
import 'package:code_base_riverpod/features/custom_grids_demo/data/grid_demo_repository.dart';
import 'package:code_base_riverpod/features/custom_grids_demo/domain/models/grid_demo_item.dart';
import 'package:code_base_riverpod/features/custom_grids_demo/presentation/widgets/grid_demo_tile.dart';
import 'package:flutter/material.dart';

class CustomGridsDemoScreen extends StatefulWidget {
  const CustomGridsDemoScreen({super.key});

  @override
  State<CustomGridsDemoScreen> createState() => _CustomGridsDemoScreenState();
}

class _CustomGridsDemoScreenState extends State<CustomGridsDemoScreen> {
  late final List<GridDemoItem> _items = GridDemoRepository.items;
  late final List<_GridScenario> _scenarios = _buildScenarios(_items);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _scenarios.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Grid Strategies'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final scenario in _scenarios)
                Tab(
                  text: scenario.title,
                  icon: scenario.icon == null ? null : Icon(scenario.icon),
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final scenario in _scenarios)
              _ScenarioView(scenario: scenario, items: _items),
          ],
        ),
      ),
    );
  }

  List<_GridScenario> _buildScenarios(List<GridDemoItem> items) {
    return <_GridScenario>[
      _GridScenario(
        title: 'Fixed Grid',
        description:
            'Uniform tiles with predictable ratio — ideal for catalogs.',
        icon: Icons.grid_view,
        layoutBuilder: (_) => FixedGridLayout(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          padding: const EdgeInsets.all(16),
          cacheExtent: 400,
        ),
        animation: GridAnimationConfig.staggered(),
      ),
      _GridScenario(
        title: 'Responsive Grid',
        description: 'Adapts column count with breakpoints to maximize space.',
        icon: Icons.view_quilt,
        layoutBuilder: (_) => ResponsiveGridLayout(
          breakpoints: const [
            ResponsiveGridBreakpoint(
              breakpoint: 480,
              crossAxisCount: 2,
              childAspectRatio: 0.95,
            ),
            ResponsiveGridBreakpoint(
              breakpoint: 768,
              crossAxisCount: 3,
              childAspectRatio: 0.9,
            ),
            ResponsiveGridBreakpoint(
              breakpoint: 1024,
              crossAxisCount: 4,
              childAspectRatio: 1.05,
            ),
            ResponsiveGridBreakpoint(
              breakpoint: 1600,
              crossAxisCount: 5,
              childAspectRatio: 1.05,
            ),
          ],
          minCrossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.all(16),
        ),
        animation: GridAnimationConfig.staggered(
          duration: const Duration(milliseconds: 360),
        ),
      ),
      _GridScenario(
        title: 'Masonry',
        description: 'Pinterest-style waterfall layout with column balancing.',
        icon: Icons.auto_awesome_mosaic,
        layoutBuilder: (items) => MasonryGridLayout(
          columnCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.all(16),
          spanResolver: (index) {
            if (index >= items.length) {
              return const GridSpanConfiguration();
            }
            final item = items[index];
            return GridSpanConfiguration(
              columnSpan: 1,
              mainAxisExtent: item.masonryHeight,
              alignment: AlignmentDirectional.topStart,
            );
          },
        ),
        animation: GridAnimationConfig.staggered(
          duration: const Duration(milliseconds: 420),
        ),
      ),
      _GridScenario(
        title: 'Aspect Ratio',
        description: 'Ratio-driven grid ensures consistent visual rhythm.',
        icon: Icons.aspect_ratio,
        layoutBuilder: (_) => RatioGridLayout(
          columnCount: 3,
          aspectRatio: 0.9,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.all(16),
        ),
        animation: GridAnimationConfig.staggered(
          duration: const Duration(milliseconds: 280),
        ),
      ),
      _GridScenario(
        title: 'Asymmetric',
        description: 'Highlighted stories span multiple columns for emphasis.',
        icon: Icons.view_comfy_alt,
        layoutBuilder: (items) => AsymmetricGridLayout(
          columnCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.all(16),
          spanResolver: (index) {
            if (index >= items.length) {
              return const GridSpanConfiguration();
            }
            final item = items[index];
            final bool highlight = item.isFeatured;
            return GridSpanConfiguration(
              columnSpan: highlight ? 2 : 1,
              aspectRatio: highlight
                  ? item.aspectRatio
                  : item.aspectRatio * 0.9,
              alignment: AlignmentDirectional.topStart,
            );
          },
        ),
        animation: GridAnimationConfig.staggered(
          duration: const Duration(milliseconds: 360),
        ),
      ),
      _GridScenario(
        title: 'Auto placement',
        description: 'Dynamic span rules with auto placement across columns.',
        icon: Icons.auto_awesome_motion,
        layoutBuilder: (items) => AutoPlacementGridLayout(
          columnCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.all(16),
          rule: AutoPlacementRule(
            maxSpan: 3,
            spanResolver: (index) {
              if (index >= items.length) {
                return const GridSpanConfiguration();
              }
              final item = items[index];
              final bool highlight = index % 7 == 0 || item.isFeatured;
              final int span = highlight ? 2 : 1;
              return GridSpanConfiguration(
                columnSpan: span,
                aspectRatio: highlight
                    ? (item.aspectRatio * 1.1).clamp(0.8, 1.6)
                    : item.aspectRatio,
              );
            },
          ),
        ),
        animation: GridAnimationConfig.staggered(
          duration: const Duration(milliseconds: 360),
        ),
      ),
      _GridScenario(
        title: 'Nested',
        description: 'Embed non-scrollable panels within scroll views.',
        icon: Icons.layers,
        usesPanel: true,
        layoutBuilder: (_) => FixedGridLayout(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
          padding: const EdgeInsets.all(12),
        ),
        animation: GridAnimationConfig.staggered(
          duration: const Duration(milliseconds: 320),
        ),
        itemCountOverride: 6,
      ),
    ];
  }
}

class _ScenarioView extends StatelessWidget {
  const _ScenarioView({required this.scenario, required this.items});

  final _GridScenario scenario;
  final List<GridDemoItem> items;

  @override
  Widget build(BuildContext context) {
    final GridLayoutConfig layout = scenario.layoutBuilder(items);
    final GridAnimationConfig animation =
        scenario.animation ?? GridAnimationConfig.none();

    final Widget header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scenario.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            scenario.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    final builder = (BuildContext context, int index) =>
        GridDemoTile(item: items[index], highlight: items[index].isFeatured);

    if (scenario.usesPanel) {
      final int subsetLength = (scenario.itemCountOverride ?? items.length)
          .clamp(0, items.length);
      final List<GridDemoItem> subset = items.take(subsetLength).toList();
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          header,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Perfect for hero sections or detail views.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AdvancedGridPanel.builder(
              layout: layout,
              itemBuilder: (context, index) => GridDemoTile(
                item: subset[index],
                highlight: subset[index].isFeatured,
              ),
              itemCount: subsetLength,
              animation: animation,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Above panel participates in a parent scroll view, demonstrating non-scroll grids.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: AdvancedGridView.builder(
            layout: layout,
            itemCount: items.length,
            animation: animation,
            itemBuilder: builder,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridScenario {
  const _GridScenario({
    required this.title,
    required this.description,
    required this.layoutBuilder,
    this.icon,
    this.animation,
    this.usesPanel = false,
    this.itemCountOverride,
  });

  final String title;
  final String description;
  final GridLayoutConfig Function(List<GridDemoItem> items) layoutBuilder;
  final IconData? icon;
  final GridAnimationConfig? animation;
  final bool usesPanel;
  final int? itemCountOverride;
}
