import 'package:code_base_riverpod/core/di/injection.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/models/demo_model.dart';
import 'package:code_base_riverpod/features/demo_feature/domain/usecases/get_demo_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expose [GetDemoUseCase] via Riverpod so UI can access it declaratively.
final getDemoUseCaseProvider = Provider<GetDemoUseCase>((ref) {
  return getIt<GetDemoUseCase>();
});

/// Load demo data and surface it as an [AsyncValue].
final demoFutureProvider = FutureProvider.autoDispose<DemoModel>((ref) async {
  final useCase = ref.watch(getDemoUseCaseProvider);
  final result = await useCase();

  return result.fold((failure) => throw failure, (data) => data);
});
