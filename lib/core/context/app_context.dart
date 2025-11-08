// lib/core/common/utils/app_context.dart
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Giữ context gốc của app (từ MaterialApp)
@lazySingleton
class AppContext {
  static final AppContext _instance = AppContext._internal();
  factory AppContext() => _instance;
  AppContext._internal();

  static BuildContext? _rootContext;

  /// Gán context (thường trong MaterialApp builder)
  void setRootContext(BuildContext context) {
    _rootContext = context;
  }

  /// Lấy context an toàn
  BuildContext get context {
    if (_rootContext == null) {
      throw Exception('AppContext.rootContext chưa được khởi tạo!');
    }
    return _rootContext!;
  }
}
