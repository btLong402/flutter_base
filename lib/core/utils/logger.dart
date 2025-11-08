import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Flutter-friendly logger (no ANSI codes, formatted layout)
class AppLogger {
  AppLogger._();

  static final _logFilter = _AppLogFilter();
  static final Logger _logger = Logger(
    filter: _logFilter,
    printer: _FlutterPrettyPrinter(includeStackTrace: true),
  );
  static final Logger _loggerNoStack = Logger(
    filter: _logFilter,
    printer: _FlutterPrettyPrinter(includeStackTrace: false),
  );

  static void configure({bool logInRelease = false}) {
    _logFilter.logInRelease = logInRelease;
  }

  static void debug(dynamic msg, {Object? error, StackTrace? stackTrace}) =>
      _loggerNoStack.d(msg, error: error, stackTrace: stackTrace);

  static void info(dynamic msg, {Object? error, StackTrace? stackTrace}) =>
      _loggerNoStack.i(msg, error: error, stackTrace: stackTrace);

  static void warning(dynamic msg, {Object? error, StackTrace? stackTrace}) =>
      _loggerNoStack.w(msg, error: error, stackTrace: stackTrace);

  static void errorLog(dynamic msg, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(msg, error: error, stackTrace: stackTrace);

  static void fatal(dynamic msg, {Object? error, StackTrace? stackTrace}) =>
      _logger.f(msg, error: error, stackTrace: stackTrace);

  // === API helpers ===
  static void logRequest(
    String method,
    String url, {
    dynamic data,
    Map<String, String>? headers,
  }) {
    info({
      'method': method.toUpperCase(),
      'url': url,
      if (headers != null && headers.isNotEmpty) 'headers': headers,
      if (data != null) 'body': data,
    });
  }

  static void logResponse(
    String url,
    int statusCode, {
    dynamic data,
    Duration? elapsed,
  }) {
    info({
      'url': url,
      'status': statusCode,
      if (elapsed != null) 'elapsed_ms': elapsed.inMilliseconds,
      if (data != null) 'body': data,
    });
  }

  static void logApiError(
    String url,
    int? statusCode, {
    String? method,
    Duration? elapsed,
    dynamic request,
    dynamic response,
    Object? error,
    StackTrace? stackTrace,
  }) {
    errorLog(
      {
        'url': url,
        if (method != null) 'method': method.toUpperCase(),
        'status': statusCode,
        if (elapsed != null) 'elapsed_ms': elapsed.inMilliseconds,
        if (request != null) 'request': request,
        if (response != null) 'response': response,
        if (error != null) 'error': error.toString(),
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Custom pretty printer for Flutter console (no ANSI)
class _FlutterPrettyPrinter extends LogPrinter {
  _FlutterPrettyPrinter({required this.includeStackTrace});
  final bool includeStackTrace;

  static final Stopwatch _uptime = Stopwatch()..start();
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  static const _icons = {
    Level.debug: '🐛 DEBUG',
    Level.info: 'ℹ️ INFO',
    Level.warning: '⚠️ WARNING',
    Level.error: '❌ ERROR',
    Level.wtf: '🔥 FATAL',
    Level.verbose: '💬 VERBOSE',
  };

  @override
  List<String> log(LogEvent event) {
    final icon = _icons[event.level] ?? event.level.name.toUpperCase();
    final now = _formatTime(event.time);
    final up = _formatElapsed(_uptime.elapsed);

    final buffer = StringBuffer();

    buffer.writeln(
      '╔══════════════════════════════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ [$icon]  🕒 $now  ⏱ +$up');
    buffer.writeln(
      '╠──────────────────────────────────────────────────────────────────────────',
    );

    for (final line in _stringify(event.message)) {
      buffer.writeln('║ $line');
    }

    if (event.error != null) {
      buffer.writeln('║ ── Error: ${event.error}');
    }

    if (includeStackTrace && event.stackTrace != null) {
      final traceLines = const LineSplitter()
          .convert(event.stackTrace.toString())
          .where((l) => l.trim().isNotEmpty)
          .take(3)
          .toList();
      if (traceLines.isNotEmpty) {
        buffer.writeln('║ ── Stack Trace:');
        for (final t in traceLines) {
          buffer.writeln('║    $t');
        }
      }
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════════════════════════════',
    );

    return [buffer.toString()];
  }

  Iterable<String> _stringify(dynamic msg) {
    if (msg == null) return const ['null'];
    if (msg is String) return LineSplitter.split(msg);
    if (msg is Map || msg is Iterable) {
      return LineSplitter.split(_encoder.convert(msg));
    }
    return LineSplitter.split(msg.toString());
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}.${t.millisecond.toString().padLeft(3, '0')}';

  String _formatElapsed(Duration d) =>
      '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}.${(d.inMilliseconds % 1000).toString().padLeft(3, '0')}';
}

/// Filter to control release logs
class _AppLogFilter extends LogFilter {
  bool logInRelease = false;

  @override
  bool shouldLog(LogEvent event) {
    if (!kReleaseMode) return true;
    if (logInRelease) return true;
    return event.level.index >= Level.warning.index;
  }
}
