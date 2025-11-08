import 'package:code_base_riverpod/core/transitions/transitions.dart';
import 'package:code_base_riverpod/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:code_base_riverpod/features/demo_feature/presentation/screens/demo_screen.dart';
import 'package:code_base_riverpod/features/infinity_scroll/presentation/screens/media_gallery_example.dart';
import 'package:code_base_riverpod/features/infinity_scroll/presentation/screens/rest_repository_example.dart';
import 'package:code_base_riverpod/features/upload_demo/presentation/screens/upload_demo_screen.dart';
import 'package:code_base_riverpod/features/custom_grids_demo/presentation/screens/custom_grids_demo_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  AppRoutes._privateConstructor();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String demo = '/demo';
  static const String mediaGalleryExample = '/media-gallery-example';
  static const String restRepoExample = '/rest-repo-example';
  static const String uploadDemo = '/upload-demo';
  static const String customGridsDemo = '/custom-grids-demo';
}

final appRouter = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) async {
      final dashboardRouteGuard = DashboardRouteGuard();
      if (!await dashboardRouteGuard.canActivate(context)) {
        return dashboardRouteGuard.redirectTo;
      }

      return null; // No redirect needed
    },
    routes: [
      buildGoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => DashboardScreen(key: state.pageKey),
        preset: TransitionPreset.slideFromRight,
      ),
      buildGoRoute(
        path: AppRoutes.demo,
        builder: (context, state) => DemoScreen(key: state.pageKey),
        preset: TransitionPreset.slideFromRight,
      ),
      buildGoRoute(
        path: AppRoutes.mediaGalleryExample,
        builder: (context, state) =>
            MediaInfiniteGridExample(key: state.pageKey),
        preset: TransitionPreset.slideFromRight,
      ),
      buildGoRoute(
        path: AppRoutes.restRepoExample,
        builder: (context, state) =>
            RestInfiniteListExample(key: state.pageKey),
        preset: TransitionPreset.slideFromRight,
      ),
      buildGoRoute(
        path: AppRoutes.uploadDemo,
        builder: (context, state) => UploadDemoScreen(key: state.pageKey),
        preset: TransitionPreset.slideFromRight,
      ),
      buildGoRoute(
        path: AppRoutes.customGridsDemo,
        builder: (context, state) => CustomGridsDemoScreen(key: state.pageKey),
        preset: TransitionPreset.slideFromRight,
      ),
    ],
  ),
);

/// Route guard mixin
/// Use this to protect routes that require authentication or permissions
mixin RouteGuard {
  /// Check if user has access to this route
  Future<bool> canActivate(BuildContext context) async {
    // Override this in your route guards
    return true;
  }

  /// Redirect location if access is denied
  String get redirectTo => AppRoutes.login;
}

//Example
class DashboardRouteGuard with RouteGuard {
  @override
  Future<bool> canActivate(BuildContext context) {
    // TODO: implement canActivate
    return super.canActivate(context);
  }
}
