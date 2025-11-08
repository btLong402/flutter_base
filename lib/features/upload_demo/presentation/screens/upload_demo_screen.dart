import 'package:code_base_riverpod/core/theme/app_inset.dart';
import 'package:code_base_riverpod/core/widgets/upload/upload.dart';
import 'package:code_base_riverpod/features/upload_demo/presentation/providers/upload_demo_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadDemoScreen extends ConsumerWidget {
  const UploadDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(uploadDemoControllerProvider);
    final summary = ref.watch(uploadDemoSummaryProvider);
    final entries = ref.watch(uploadDemoEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Experience Demo')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 32.0;
          final isWide = constraints.maxWidth >= 920;
          return Scrollbar(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _MainPanel(controller: controller)),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: _InsightsColumn(
                                summary: summary,
                                entries: entries,
                                controller: controller,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MainPanel(controller: controller),
                            const SizedBox(height: 24),
                            _InsightsColumn(
                              summary: summary,
                              entries: entries,
                              controller: controller,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MainPanel extends StatelessWidget {
  const _MainPanel({required this.controller});

  final UploadController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stress test the adaptive uploader',
                  style: theme.textTheme.titleLarge,
                ),
                AppInset.gapSmall,
                Text(
                  'Pick a mixture of images, videos, or documents. The controller simulates network responses, including retries and verification checks.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                AppInset.gapMedium,
                const _TipsList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        UploadWidget(
          controller: controller,
          tileDecoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          onUploadCompleted: (completed) {
            final messenger = ScaffoldMessenger.maybeOf(context);
            if (messenger == null) {
              return;
            }
            final message = completed.length == 1
                ? 'Uploaded ${completed.first.item.name}'
                : 'Uploaded ${completed.length} files successfully';
            messenger.showSnackBar(SnackBar(content: Text(message)));
          },
        ),
      ],
    );
  }
}

class _TipsList extends StatelessWidget {
  const _TipsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Tip(
          text: 'Desktop platforms leverage file streams for memory safety.',
        ),
        AppInset.gapSmall,
        _Tip(
          text: 'Videos autoplay silently; tap retry to mimic unstable links.',
        ),
        AppInset.gapSmall,
        _Tip(
          text: 'Status polls verify backend processing after uploads succeed.',
        ),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightsColumn extends StatelessWidget {
  const _InsightsColumn({
    required this.summary,
    required this.entries,
    required this.controller,
  });

  final UploadDemoSummary summary;
  final List<UploadEntryState> entries;
  final UploadController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live analytics', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SummaryChip(
                      label: 'Total',
                      value: summary.total,
                      color: theme.colorScheme.secondaryContainer,
                      textColor: theme.colorScheme.onSecondaryContainer,
                    ),
                    _SummaryChip(
                      label: 'Success',
                      value: summary.success,
                      color: theme.colorScheme.primaryContainer,
                      textColor: theme.colorScheme.onPrimaryContainer,
                    ),
                    _SummaryChip(
                      label: 'Verifying',
                      value: summary.verifying,
                      color: theme.colorScheme.surfaceContainerHigh,
                      textColor: theme.colorScheme.onSurfaceVariant,
                    ),
                    _SummaryChip(
                      label: 'Uploading',
                      value: summary.uploading,
                      color: theme.colorScheme.surfaceContainerHigh,
                      textColor: theme.colorScheme.onSurfaceVariant,
                    ),
                    if (summary.failed > 0)
                      _SummaryChip(
                        label: 'Failed',
                        value: summary.failed,
                        color: theme.colorScheme.errorContainer,
                        textColor: theme.colorScheme.onErrorContainer,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Use "Upload all" to observe how the controller batches progress events and transitions through verifying states when remote IDs are returned.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _ActivityList(entries: entries, controller: controller),
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  final String label;
  final int value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: theme.textTheme.titleLarge?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.entries, required this.controller});

  final List<UploadEntryState> entries;
  final UploadController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent activity', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Upload files to populate the activity log and evaluate progress callbacks.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent activity', style: theme.textTheme.titleMedium),
            const Spacer(),
            IconButton(
              tooltip: 'Clear all',
              onPressed: controller.isUploading
                  ? null
                  : () {
                      final ids = entries
                          .map((entry) => entry.item.id)
                          .toList();
                      for (final id in ids) {
                        controller.remove(id);
                      }
                    },
              icon: const Icon(Icons.clear_all),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final stageLabel = _stageLabel(entry.stage);
            return Row(
              children: [
                Expanded(
                  child: Text(
                    entry.item.name,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatBytes(entry.item.sizeInBytes),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _stageColor(context, entry.stage),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    stageLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _stageLabel(UploadStage stage) {
    switch (stage) {
      case UploadStage.idle:
      case UploadStage.queued:
        return 'Pending';
      case UploadStage.uploading:
        return 'Uploading';
      case UploadStage.verifying:
        return 'Verifying';
      case UploadStage.success:
        return 'Completed';
      case UploadStage.failure:
        return 'Failed';
      case UploadStage.canceled:
        return 'Canceled';
    }
  }

  Color _stageColor(BuildContext context, UploadStage stage) {
    final scheme = Theme.of(context).colorScheme;
    switch (stage) {
      case UploadStage.success:
        return scheme.primaryContainer;
      case UploadStage.verifying:
        return scheme.secondaryContainer;
      case UploadStage.uploading:
        return scheme.surfaceContainerHigh;
      case UploadStage.failure:
        return scheme.errorContainer;
      case UploadStage.canceled:
        return scheme.surfaceContainerHighest;
      default:
        return scheme.surfaceContainerHighest;
    }
  }
}
