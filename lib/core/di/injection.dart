import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Service locator instance
final getIt = GetIt.instance;

/// Initialize dependency injection
/// Call this in main() before runApp()
@InjectableInit(initializerName: 'init', preferRelativeImports: true)
Future<void> configureDependencies() async {
  await getIt.init();
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}

/*
 * USAGE EXAMPLES:
 * 
 * 1. Register a singleton (created once, shared across app):
 *    getIt.registerSingleton<MyService>(MyService());
 * 
 * 2. Register a lazy singleton (created on first access):
 *    getIt.registerLazySingleton<MyService>(() => MyService());
 * 
 * 3. Register a factory (new instance each time):
 *    getIt.registerFactory<MyService>(() => MyService());
 * 
 * 4. Register with parameters:
 *    getIt.registerFactoryParam<MyService, String, void>(
 *      (param1, _) => MyService(param1),
 *    );
 * 
 * 5. Access registered service:
 *    final service = getIt<MyService>();
 *    // or
 *    final service = getIt.get<MyService>();
 * 
 * 6. Check if registered:
 *    if (getIt.isRegistered<MyService>()) {
 *      // ...
 *    }
 * 
 * 7. Unregister:
 *    getIt.unregister<MyService>();
 */
