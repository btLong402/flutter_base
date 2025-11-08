import 'package:flutter/material.dart';

import 'package:code_base_riverpod/core/widgets/custom_grids/custom_grids.dart';

void main() {
  runApp(const HyperGridDemoApp());
}

class HyperGridDemoApp extends StatelessWidget {
  const HyperGridDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyper Grid Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const _DemoHome(),
    );
  }
}

class _DemoHome extends StatefulWidget {
  const _DemoHome();

  @override
  State<_DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<_DemoHome>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(
    length: _tabs.length,
    vsync: this,
  );

  static final List<_DemoTab> _tabs = <_DemoTab>[
    _DemoTab(
      label: 'Fixed',
      delegate: const HyperFixedGridDelegate(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
    ),
    _DemoTab(
      label: 'Flexible',
      delegate: const HyperFlexibleGridDelegate(
        minTileWidth: 180,
        breakpoints: [
          HyperGridBreakpoint(width: 600, columns: 3),
          HyperGridBreakpoint(width: 960, columns: 4),
        ],
      ),
    ),
    _DemoTab(
      label: 'Masonry',
      delegate: HyperMasonryGridDelegate(
        columnCount: 3,
        sizeEstimator: (index) => 120 + (index % 5) * 24,
      ),
    ),
    _DemoTab(
      label: 'Aspect',
      delegate: const HyperAspectRatioGridDelegate(
        aspectRatio: 16 / 9,
        minTileWidth: 200,
      ),
    ),
    _DemoTab(
      label: 'Nested',
      delegate: const HyperNestedGridDelegate(
        crossAxisCount: 2,
        behavior: HyperNestedScrollBehavior.independent,
        minTileExtent: 220,
      ),
    ),
    _DemoTab(
      label: 'Asym',
      delegate: HyperAsymmetricGridDelegate(
        maxColumns: 4,
        tileResolver: (index) {
          final span = 1 + (index % 3);
          return HyperAsymmetricTileConfig(
            crossAxisSpan: span,
            aspectRatio: span == 3 ? 16 / 9 : 4 / 3,
          );
        },
      ),
    ),
    _DemoTab(
      label: 'Auto',
      delegate: HyperAutoPlacementGridDelegate(
        maxColumns: 4,
        strategy: HyperAutoPlacementStrategy.greedy,
        sizeResolver: (index) {
          final span = index % 5 == 0 ? 2 : 1;
          return HyperAutoPlacementSize(
            crossAxisSpan: span,
            mainAxisExtent: 140 + (index % 4) * 40,
          );
        },
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Grid Engines'),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: _tabs
            .map((tab) => _GridDemoView(delegate: tab.delegate))
            .toList(),
      ),
    );
  }
}

class _GridDemoView extends StatelessWidget {
  const _GridDemoView({required this.delegate});

  final HyperGridDelegateBase delegate;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        HyperSliverGrid.builder(
          gridDelegate: delegate,
          itemCount: 40,
          animationConfig: const HyperGridAnimationConfig(
            enableImplicitTransitions: true,
          ),
          itemBuilder: (context, index) {
            return _DemoTile(index: index);
          },
        ),
      ],
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Center(child: Text('#$index', style: theme.textTheme.titleMedium)),
    );
  }
}

class _DemoTab {
  const _DemoTab({required this.label, required this.delegate});

  final String label;
  final HyperGridDelegateBase delegate;
}
