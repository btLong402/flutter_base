import 'package:code_base_riverpod/core/error/failures.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/models/demo_model.dart';
import 'package:code_base_riverpod/features/demo_feature/presentation/providers/demo_providers.dart';
import 'package:code_base_riverpod/features/demo_feature/presentation/widgets/demo_detail_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DemoScreen extends ConsumerWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoAsync = ref.watch(demoFutureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Demo Feature')),
      body: RefreshIndicator(
        // Allow pull-to-refresh regardless of the current state
        onRefresh: () async {
          ref.invalidate(demoFutureProvider);
          try {
            await ref.read(demoFutureProvider.future);
          } catch (_) {
            // Ignore errors during pull-to-refresh; UI already reflects them.
          }
        },
        child: demoAsync.when(
          data: (demo) => _DataView(demo: demo),
          loading: () => const _LoadingView(),
          error: (error, stackTrace) => _ErrorView(
            message: (error is Failure) ? error.message : 'Unexpected error',
            onRetry: () {
              ref.invalidate(demoFutureProvider);
            },
          ),
        ),
      ),
    );
  }
}

class _DataView extends StatelessWidget {
  const _DataView({required this.demo});

  final DemoModel demo;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 16),
        DemoDetailCard(demo: demo),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 240),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 160),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ],
    );
  }
}
