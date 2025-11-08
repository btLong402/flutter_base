import 'package:code_base_riverpod/core/widgets/upload/upload.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a mock upload service tailored for the demo experience.
final uploadDemoServiceProvider = Provider<UploadService>((ref) {
  return MockUploadService(
    failRate: 0.2,
    minDelay: const Duration(milliseconds: 480),
    maxDelay: const Duration(milliseconds: 2200),
    statusDelay: const Duration(milliseconds: 900),
  );
});

/// Binds the [UploadController] to Riverpod so the UI can react to its changes.
final uploadDemoControllerProvider =
    ChangeNotifierProvider.autoDispose<UploadController>((ref) {
      final service = ref.watch(uploadDemoServiceProvider);
      return UploadController(service: service);
    });

/// Exposes the controller entries for lightweight selectors.
final uploadDemoEntriesProvider = Provider.autoDispose<List<UploadEntryState>>((
  ref,
) {
  final controller = ref.watch(uploadDemoControllerProvider);
  return controller.entries.toList(growable: false);
});

/// Aggregated insight values used by the analytics chips at the bottom of the
/// screen.
final uploadDemoSummaryProvider = Provider.autoDispose<UploadDemoSummary>((
  ref,
) {
  final entries = ref.watch(uploadDemoEntriesProvider);
  var success = 0;
  var verifying = 0;
  var uploading = 0;
  var failed = 0;
  for (final entry in entries) {
    switch (entry.stage) {
      case UploadStage.success:
        success++;
        break;
      case UploadStage.verifying:
        verifying++;
        break;
      case UploadStage.uploading:
        uploading++;
        break;
      case UploadStage.failure:
        failed++;
        break;
      default:
        break;
    }
  }
  return UploadDemoSummary(
    total: entries.length,
    success: success,
    verifying: verifying,
    uploading: uploading,
    failed: failed,
  );
});

class UploadDemoSummary {
  const UploadDemoSummary({
    required this.total,
    required this.success,
    required this.verifying,
    required this.uploading,
    required this.failed,
  });

  final int total;
  final int success;
  final int verifying;
  final int uploading;
  final int failed;
}
