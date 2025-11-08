import 'package:code_base_riverpod/core/config/environment.dart';
import 'package:code_base_riverpod/core/context/app_context.dart';
import 'package:code_base_riverpod/core/di/injection.dart';
import 'package:code_base_riverpod/core/router/app_router.dart';
import 'package:code_base_riverpod/core/storage/local_storage.dart';
import 'package:code_base_riverpod/core/theme/them_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    final supportDir = await getApplicationSupportDirectory();
    Hive.init(supportDir.path);
  }
  // Initialize SharedPreferences
  await LocalStorage.init();
  await EnvironmentConfig.load(
    env: (kDebugMode ? EnvironmentName.development : EnvironmentName.staging)
        .name,
  );
  await configureDependencies();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);

    final router = ref.watch(appRouter);

    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: kDebugMode,
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      themeMode: theme,
      routerConfig: router,
      locale: const Locale('en', 'US'),
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        getIt<AppContext>().setRootContext(context);
        return MediaQuery(
          // Lock text scaling for consistent UI
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
