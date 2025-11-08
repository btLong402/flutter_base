import 'package:flutter/material.dart';

import 'upload_controller.dart';
import 'upload_models.dart';
import 'upload_picker.dart';
import 'upload_preview_tile.dart';
import 'upload_service.dart';

class UploadWidget extends StatefulWidget {
  const UploadWidget({
    super.key,
    this.service,
    this.controller,
    this.picker,
    this.title = 'Upload files',
    this.subtitle = 'Select images, videos, or documents to upload.',
    this.leading,
    this.decoration,
    this.padding = const EdgeInsets.all(20),
    this.tileDecoration,
    this.onUploadCompleted,
    this.enableAutoStatusRefresh = true,
  });

  final UploadService? service;
  final UploadController? controller;
  final UploadPicker? picker;
  final String title;
  final String subtitle;
  final Widget? leading;
  final Decoration? decoration;
  final EdgeInsets padding;
  final Decoration? tileDecoration;
  final void Function(List<UploadEntryState> entries)? onUploadCompleted;
  final bool enableAutoStatusRefresh;

  @override
  State<UploadWidget> createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  late UploadController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      final service = widget.service;
      assert(
        service != null,
        'UploadWidget requires a service when no controller is supplied.',
      );
      _controller = UploadController(service: service!, picker: widget.picker);
      _ownsController = true;
    }
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        final service = widget.service;
        assert(
          service != null,
          'UploadWidget requires a service when no controller is supplied.',
        );
        _controller = UploadController(
          service: service!,
          picker: widget.picker,
        );
        _ownsController = true;
      }
      _controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    setState(() {});
    if (!_controller.isUploading) {
      final completed = _controller.entries
          .where((entry) => entry.stage == UploadStage.success)
          .toList();
      if (completed.isNotEmpty) {
        widget.onUploadCompleted?.call(completed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration =
        widget.decoration ??
        BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        );
    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              title: widget.title,
              subtitle: widget.subtitle,
              leading: widget.leading,
            ),
            const SizedBox(height: 16),
            _ActionRow(controller: _controller),
            const SizedBox(height: 20),
            _EntriesList(
              controller: _controller,
              tileDecoration: widget.tileDecoration,
              onStatusRefresh: widget.enableAutoStatusRefresh
                  ? (id) => _controller.refreshStatus(id)
                  : null,
            ),
            const SizedBox(height: 16),
            _SummaryFooter(controller: _controller),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, this.leading});

  final String title;
  final String subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading ??
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.controller});

  final UploadController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: controller.isPicking || controller.isUploading
              ? null
              : () {
                  controller.pickAndAdd();
                },
          icon: controller.isPicking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(controller.isPicking ? 'Selecting…' : 'Select files'),
        ),
        if (controller.entries.isNotEmpty)
          OutlinedButton.icon(
            onPressed: controller.isUploading ? null : controller.uploadAll,
            icon: controller.isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(controller.isUploading ? 'Uploading…' : 'Upload all'),
          ),
      ],
    );
  }
}

class _EntriesList extends StatelessWidget {
  const _EntriesList({
    required this.controller,
    this.tileDecoration,
    this.onStatusRefresh,
  });

  final UploadController controller;
  final Decoration? tileDecoration;
  final void Function(String id)? onStatusRefresh;

  @override
  Widget build(BuildContext context) {
    final entries = controller.entries;
    if (entries.isEmpty) {
      return const _EmptyState();
    }
    return Column(
      children: [
        for (final entry in entries) ...[
          UploadPreviewTile(
            state: entry,
            decoration: tileDecoration,
            onRemove: () => controller.remove(entry.item.id),
            onRetry: entry.stage == UploadStage.failure
                ? () => controller.retry(entry.item.id)
                : null,
            onCheckStatus: onStatusRefresh != null
                ? () => onStatusRefresh!(entry.item.id)
                : null,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.drive_folder_upload_outlined,
            size: 42,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text('No files selected yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Tap “Select files” to choose images, videos, or documents from your device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SummaryFooter extends StatelessWidget {
  const _SummaryFooter({required this.controller});

  final UploadController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = controller.entries;
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    final total = entries.length;
    final completed = entries
        .where((e) => e.stage == UploadStage.success)
        .length;
    final failed = entries.where((e) => e.stage == UploadStage.failure).length;
    final inProgress = entries
        .where((e) => e.stage == UploadStage.uploading)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 12),
        Text(
          'Summary',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _Chip(
              label: 'Total $total',
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.primary,
            ),
            _Chip(
              label: 'Completed $completed',
              color: theme.colorScheme.surfaceVariant,
              textColor: theme.colorScheme.primary,
            ),
            _Chip(
              label: 'Uploading $inProgress',
              color: theme.colorScheme.surfaceVariant,
              textColor: theme.colorScheme.onSurfaceVariant,
            ),
            if (failed > 0)
              _Chip(
                label: 'Failed $failed',
                color: theme.colorScheme.errorContainer,
                textColor: theme.colorScheme.onErrorContainer,
              ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: textColor)),
    );
  }
}
