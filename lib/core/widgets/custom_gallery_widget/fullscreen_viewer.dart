import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

import '../custom_image_widget/custom_image_widget.dart';
import 'media_viewer.dart';

/// Fullscreen experience with pinch-to-zoom, swipe navigation, and video support.
class GalleryFullscreenViewer extends StatefulWidget {
  const GalleryFullscreenViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.autoPlayVideos = true,
    this.loopVideos = true,
  });

  final List<GalleryMediaItem> items;
  final int initialIndex;
  final bool autoPlayVideos;
  final bool loopVideos;

  @override
  State<GalleryFullscreenViewer> createState() =>
      _GalleryFullscreenViewerState();
}

class _GalleryFullscreenViewerState extends State<GalleryFullscreenViewer>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _resetAnimationController;
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, TransformationController> _zoomControllers = {};
  final Map<int, Object> _videoErrors = {};
  final Map<int, Future<void>> _loadingFutures = {};

  VoidCallback? _resetAnimationListener;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _resetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _currentIndex.value = widget.initialIndex;

    _initializeForIndex(widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchAround(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    _resetAnimationListener?.let(_resetAnimationController.removeListener);
    _resetAnimationController.dispose();
    _pageController.dispose();
    _currentIndex.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _currentIndex,
            builder: (context, index, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${index + 1}/${widget.items.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        onPageChanged: _handlePageChanged,
        itemBuilder: (context, index) => _buildPage(index),
      ),
    );
  }

  Widget _buildPage(int index) {
    final item = widget.items[index];
    if (item.type == GalleryMediaType.video) {
      return _buildVideo(index, item);
    }

    return _buildZoomableImage(index, item);
  }

  Widget _buildZoomableImage(int index, GalleryMediaItem item) {
    final controller = _zoomControllers.putIfAbsent(
      index,
      () => TransformationController(),
    );

    Widget child = CustomImageWidget(
      source: item.imageSource ?? item.thumbnailSource!,
      fit: BoxFit.contain,
      backgroundColor: Colors.black,
      placeholder: const _FullscreenPlaceholder(),
    );

    if (item.heroTag != null) {
      child = Hero(tag: item.heroTag!, child: child);
    }

    return GestureDetector(
      onDoubleTap: () => _handleDoubleTap(index),
      child: InteractiveViewer(
        transformationController: controller,
        minScale: 1,
        maxScale: 4,
        panEnabled: true,
        scaleEnabled: true,
        child: child,
      ),
    );
  }

  Widget _buildVideo(int index, GalleryMediaItem item) {
    final controller = _videoControllers[index];
    final error = _videoErrors[index];

    Widget content;
    if (error != null) {
      content = _buildError(error);
    } else if (controller == null || !_isControllerReady(controller)) {
      content = const _FullscreenPlaceholder();
    } else {
      content = GestureDetector(
        onTap: () {
          if (!mounted) return;
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
          setState(() {});
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio == 0
                    ? 16 / 9
                    : controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            if (!controller.value.isPlaying)
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 56,
              ),
          ],
        ),
      );
    }

    if (item.heroTag != null) {
      content = Hero(tag: item.heroTag!, child: content);
    }

    return Center(child: content);
  }

  Widget _buildError(Object error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 36),
          const SizedBox(height: 12),
          Text(
            'Unable to load media',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handlePageChanged(int index) async {
    _currentIndex.value = index;
    _resetZoomIfNeeded(index - 1);
    _resetZoomIfNeeded(index + 1);
    _pauseAllExcept(index);
    _initializeForIndex(index);
    _prefetchAround(index);
  }

  void _resetZoomIfNeeded(int index) {
    final controller = _zoomControllers[index];
    if (controller == null) return;
    if (_isZoomed(controller)) {
      controller.value = Matrix4.identity();
    }
  }

  void _pauseAllExcept(int index) {
    for (final entry in _videoControllers.entries) {
      if (entry.key == index) {
        if (widget.autoPlayVideos && !_videoErrors.containsKey(index)) {
          entry.value.play();
        }
      } else {
        entry.value.pause();
      }
    }
  }

  void _handleDoubleTap(int index) {
    final controller = _zoomControllers[index];
    if (controller == null) {
      return;
    }

    final begin = controller.value.clone();
    final targetIsIdentity = _isZoomed(controller);
    final end = targetIsIdentity ? Matrix4.identity() : Matrix4.identity()
      ..scale(2.2);

    _animateTransformation(index, begin, end);
  }

  void _animateTransformation(int index, Matrix4 begin, Matrix4 end) {
    _resetAnimationController
      ..stop()
      ..reset();

    final animation = Matrix4Tween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _resetAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    if (_resetAnimationListener != null) {
      _resetAnimationController.removeListener(_resetAnimationListener!);
    }

    _resetAnimationListener = () {
      final controller = _zoomControllers[index];
      if (controller != null) {
        controller.value = animation.value;
      }
    };

    _resetAnimationController.addListener(_resetAnimationListener!);
    _resetAnimationController.forward();
  }

  Future<void> _initializeForIndex(int index) async {
    if (index < 0 || index >= widget.items.length) {
      return;
    }

    final item = widget.items[index];
    if (item.type != GalleryMediaType.video) {
      return;
    }

    _loadingFutures[index] ??= _setupVideoController(index, item);
    await _loadingFutures[index];
  }

  Future<void> _setupVideoController(int index, GalleryMediaItem item) async {
    try {
      if (_videoControllers.containsKey(index)) {
        final controller = _videoControllers[index]!;
        if (widget.loopVideos) {
          controller.setLooping(true);
        }
        if (widget.autoPlayVideos && !controller.value.isPlaying) {
          await controller.play();
        }
        return;
      }

      final controller = await _createVideoController(item.videoSource!);
      await controller.initialize();
      controller.setLooping(widget.loopVideos);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoControllers[index] = controller;
      });

      if (widget.autoPlayVideos) {
        await controller.play();
      }
    } catch (error) {
      _videoErrors[index] = error;
    }
  }

  Future<VideoPlayerController> _createVideoController(
    GalleryVideoSource source,
  ) async {
    if (source is NetworkGalleryVideoSource) {
      final cache = source.cacheManager ?? GalleryCacheManager.instance;
      FileInfo? fileInfo = await cache.getFileFromCache(source.url);
      fileInfo ??= await cache.downloadFile(
        source.url,
        key: source.url,
        authHeaders: source.headers,
      );
      return VideoPlayerController.file(fileInfo.file);
    }

    if (source is AssetGalleryVideoSource) {
      return VideoPlayerController.asset(
        source.assetPath,
        package: source.package,
      );
    }

    if (source is FileGalleryVideoSource) {
      return VideoPlayerController.file(source.file);
    }

    throw UnsupportedError('Unsupported video source: ${source.runtimeType}');
  }

  Future<void> _prefetchAround(int index) async {
    final candidates = <int>{
      index - 1,
      index + 1,
    }.where((value) => value >= 0 && value < widget.items.length);

    for (final candidate in candidates) {
      final item = widget.items[candidate];
      if (item.type == GalleryMediaType.video &&
          item.videoSource is NetworkGalleryVideoSource) {
        final source = item.videoSource as NetworkGalleryVideoSource;
        final cache = source.cacheManager ?? GalleryCacheManager.instance;
        final cached = await cache.getFileFromCache(source.url);
        if (cached == null) {
          // Fire and forget download to warm the cache.
          unawaited(
            cache.downloadFile(
              source.url,
              key: source.url,
              authHeaders: source.headers,
            ),
          );
        }
      }
    }
  }

  bool _isControllerReady(VideoPlayerController controller) {
    return controller.value.isInitialized;
  }

  bool _isZoomed(TransformationController controller) {
    return controller.value.getMaxScaleOnAxis() > 1.05;
  }
}

class _FullscreenPlaceholder extends StatelessWidget {
  const _FullscreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 48,
        width: 48,
        child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
      ),
    );
  }
}

extension<T> on T? {
  void let(void Function(T value) block) {
    final self = this;
    if (self != null) {
      block(self);
    }
  }
}
