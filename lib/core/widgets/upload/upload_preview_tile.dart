import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../custom_image_widget/custom_image_widget.dart';
import '../custom_image_widget/image_loader.dart';
import 'upload_models.dart';
import 'upload_progress_indicator.dart';
import 'upload_video_controller.dart';

class UploadPreviewTile extends StatelessWidget {
  const UploadPreviewTile({
    super.key,
    required this.state,
    this.onRemove,
    this.onRetry,
    this.onCheckStatus,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
  });

  final UploadEntryState state;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;
  final VoidCallback? onCheckStatus;
  final Decoration? decoration;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration:
          decoration ??
          BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MediaPreview(state: state),
            const SizedBox(width: 16),
            Expanded(
              child: _MetadataSection(
                state: state,
                onCheckStatus: onCheckStatus,
              ),
            ),
            const SizedBox(width: 8),
            _TrailingActions(
              state: state,
              onRemove: onRemove,
              onRetry: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.state});

  final UploadEntryState state;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final size = 72.0;
    switch (state.item.mediaType) {
      case UploadMediaType.image:
        final remoteUrl = state.result?.remoteUrl;
        if (remoteUrl != null) {
          return ClipRRect(
            borderRadius: radius,
            child: CustomImageWidget(
              source: CustomImageSource.network(remoteUrl),
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          );
        }
        if (state.item.thumbnailBytes != null) {
          return ClipRRect(
            borderRadius: radius,
            child: Image.memory(
              state.item.thumbnailBytes!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          );
        }
        return _PlaceholderBox(icon: Icons.image_outlined);
      case UploadMediaType.video:
        return ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            width: size,
            height: size,
            child: UploadVideoPreview(item: state.item),
          ),
        );
      case UploadMediaType.file:
        return _PlaceholderBox(icon: Icons.insert_drive_file_outlined);
    }
  }
}

class _PlaceholderBox extends StatelessWidget {
  const _PlaceholderBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class UploadVideoPreview extends StatefulWidget {
  const UploadVideoPreview({required this.item, super.key});

  final UploadItem item;

  @override
  State<UploadVideoPreview> createState() => _UploadVideoPreviewState();
}

class _UploadVideoPreviewState extends State<UploadVideoPreview> {
  VideoPlayerController? _controller;
  Future<void>? _initializing;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final controller = await createVideoController(widget.item);
    if (!mounted) return;
    if (controller == null) {
      setState(() {
        _controller = null;
        _initializing = null;
      });
      return;
    }
    setState(() {
      _controller = controller;
      _initializing = controller.initialize();
    });
    await _initializing;
    if (!mounted) return;
    controller
      ..setLooping(true)
      ..setVolume(0);
    controller.play();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final init = _initializing;
    if (controller == null || init == null) {
      return const _PlaceholderBox(icon: Icons.smart_display_outlined);
    }
    return FutureBuilder<void>(
      future: init,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: Alignment.center,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
              const Icon(Icons.play_arrow, color: Colors.white70),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.state, required this.onCheckStatus});

  final UploadEntryState state;
  final VoidCallback? onCheckStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle =
        '${formatBytes(state.item.sizeInBytes)} • ${_describeStage(state.stage)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.item.name,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        UploadProgressIndicator(stage: state.stage, progress: state.progress),
        if ((state.stage == UploadStage.success ||
                state.stage == UploadStage.verifying) &&
            onCheckStatus != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton.icon(
              onPressed: onCheckStatus,
              icon: const Icon(Icons.autorenew, size: 18),
              label: const Text('Refresh status'),
            ),
          ),
      ],
    );
  }

  String _describeStage(UploadStage stage) {
    switch (stage) {
      case UploadStage.idle:
      case UploadStage.queued:
        return 'Pending';
      case UploadStage.uploading:
        return 'Uploading';
      case UploadStage.verifying:
        return 'Verifying';
      case UploadStage.success:
        return 'Complete';
      case UploadStage.failure:
        return 'Failed';
      case UploadStage.canceled:
        return 'Canceled';
    }
  }
}

class _TrailingActions extends StatelessWidget {
  const _TrailingActions({required this.state, this.onRemove, this.onRetry});

  final UploadEntryState state;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];
    if (onRemove != null && state.stage != UploadStage.uploading) {
      buttons.add(
        IconButton(
          tooltip: 'Remove',
          onPressed: onRemove,
          icon: const Icon(Icons.close),
        ),
      );
    }
    if (onRetry != null && state.stage == UploadStage.failure) {
      buttons.add(
        IconButton(
          tooltip: 'Retry',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
        ),
      );
    }
    return Column(children: buttons);
  }
}
