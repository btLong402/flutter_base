import 'dart:math';

import 'package:code_base_riverpod/core/utils/logger.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/infinite_scroll/infinite_scroll.dart';

/// Fake REST repository used for demonstrating pagination and error handling.
class RestRepository {
  RestRepository({this.failEvery = 0});

  final int failEvery;
  final Random _random = Random(24);

  Future<List<Post>> fetchPosts({
    required int page,
    required int pageSize,
  }) async {
    AppLogger.debug('Fetching page $page with size $pageSize');
    if (failEvery > 0 && page % failEvery == 0) {
      throw Exception('Server responded with 500 for page $page');
    }

    return List.generate(pageSize, (index) {
      final id = (page - 1) * pageSize + index + 1;
      return Post(
        id: id,
        title: 'Article $id',
        subtitle: 'Server driven content, page $page item $index',
        thumbnailUrl: 'https://picsum.photos/seed/rest$id/320/200',
      );
    });
  }

  Future<void> prefetchThumbnails(List<Post> posts) async {
    // In production wire this into a caching layer such as CachedNetworkImage
    // or precacheImage with the surrounding BuildContext. Here we simply wait
    // a frame to emulate asynchronous work.
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }
}

class Post {
  const Post({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.thumbnailUrl,
  });

  final int id;
  final String title;
  final String subtitle;
  final String thumbnailUrl;
}

/// Example list that consumes [PaginationController] with a REST-style repository.
class RestInfiniteListExample extends StatefulWidget {
  const RestInfiniteListExample({super.key});

  @override
  State<RestInfiniteListExample> createState() =>
      _RestInfiniteListExampleState();
}

class _RestInfiniteListExampleState extends State<RestInfiniteListExample> {
  late final RestRepository _repository;
  late final PaginationController<Post> _controller;

  @override
  void initState() {
    super.initState();
    _repository = RestRepository(failEvery: 100);
    _controller = PaginationController<Post>(
      pageSize: 30,
      preloadFraction: 0.7,
      keepPagesInMemory: null,
      debounceDuration: const Duration(milliseconds: 260),
      loadPage: ({required int page, required int pageSize}) =>
          _repository.fetchPosts(page: page, pageSize: pageSize),
      onPageLoaded: _repository.prefetchThumbnails,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollView<Post>(
      controller: _controller,
      layout: InfiniteScrollLayout.list,
      padding: const EdgeInsets.all(16),
      itemExtent: 124,
      useSlivers: true,
      sliverAppBar: SliverAppBar(
        pinned: true,
        floating: false,
        title: const Text('Memories'),
        expandedHeight: 120,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '5,000+ media items with thumbnail caching and smooth scrolling.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index, post) {
        return _PostTile(post: post);
      },
      errorBuilder: (context, error, retry) =>
          _ErrorTile(error: error, onRetry: retry),
      emptyBuilder: (context) => const _EmptyState(),
      loadingBuilder: (context) => const _LoadingState(),
      semanticsLabelBuilder: (item, index) => 'Article ${item.id}',
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 124,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 132,
                child: Image.network(post.thumbnailUrl, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(post.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      post.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 12),
        Text(
          'Oops, something broke',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$error',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.dynamic_feed_outlined,
          size: 48,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: 12),
        Text('No articles yet', style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Pull down to refresh and fetch new stories.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
