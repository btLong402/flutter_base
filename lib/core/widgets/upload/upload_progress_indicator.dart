import 'package:flutter/material.dart';

import 'upload_models.dart';

class UploadProgressIndicator extends StatelessWidget {
  const UploadProgressIndicator({
    super.key,
    required this.stage,
    required this.progress,
  });

  final UploadStage stage;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (stage) {
      case UploadStage.uploading:
      case UploadStage.verifying:
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: stage == UploadStage.uploading ? progress : null,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        );
      case UploadStage.success:
        return _StatusLabel(
          icon: Icons.check_circle,
          color: theme.colorScheme.primary,
          label: 'Uploaded',
        );
      case UploadStage.failure:
        return _StatusLabel(
          icon: Icons.error_outline,
          color: theme.colorScheme.error,
          label: 'Failed',
        );
      case UploadStage.canceled:
        return _StatusLabel(
          icon: Icons.block,
          color: theme.colorScheme.outline,
          label: 'Canceled',
        );
      case UploadStage.idle:
      case UploadStage.queued:
        return _StatusLabel(
          icon: Icons.pause_circle_outline,
          color: theme.colorScheme.outline,
          label: 'Ready',
        );
    }
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
