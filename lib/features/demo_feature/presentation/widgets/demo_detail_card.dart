import 'package:code_base_riverpod/features/demo_feature/domain/models/demo_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DemoDetailCard extends StatelessWidget {
  const DemoDetailCard({super.key, required this.demo});

  final DemoModel demo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = demo.createdAt;
    final createdLabel = createdAt != null
        ? DateFormat.yMMMd().add_jm().format(createdAt.toLocal())
        : 'Not available';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          demo.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${demo.id}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(demo.isActive ? 'Active' : 'Inactive'),
                    backgroundColor: demo.isActive
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHigh,
                    side: BorderSide.none,
                  ),
                ],
              ),
              if (demo.description != null && demo.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(demo.description!, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  _InfoTile(label: 'Count', value: demo.count.toString()),
                  const SizedBox(width: 12),
                  _InfoTile(label: 'Created', value: createdLabel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
