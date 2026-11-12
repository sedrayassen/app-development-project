import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLogger {
  static const int _maxBody = 1500;

  static void info(String tag, String message) {
    if (kDebugMode) debugPrint('[INFO] $tag $message');
  }

  static void request(String tag, String method, String path,
    {Map<String, dynamic>? query, Object? body}) {
  if (!kDebugMode) return;
  final q = (query == null || query.isEmpty) ? '' : '  query: $query';
  final b = body == null ? '' : '  body: ${_short(body)}';
  debugPrint('[REQ] $tag → $method $path$q$b');
}

  static void response(String tag, int? status, dynamic body) {
    if (!kDebugMode) return;
    debugPrint('[RES] $tag ← $status ${_short(body)}');
  }

  static void error(String tag, Object error, [StackTrace? stack]) {
    if (!kDebugMode) return;
    debugPrint('[ERR] $tag ${error.runtimeType}: $error');
    if (stack != null) debugPrint(stack.toString());
  }

  static void dio(String tag, DioException e) {
    if (!kDebugMode) return;
    final headers = e.requestOptions.headers;
    debugPrint(
      '[ERR] $tag DioException\n'
      '      type: ${e.type}\n'
      '      method: ${e.requestOptions.method}\n'
      '      url: ${e.requestOptions.uri}\n'
      '      status: ${e.response?.statusCode}\n'
      '      hasAuthHeader: ${headers['Authorization'] != null}\n'
      '      message: ${e.message}\n'
      '      underlying: ${e.error}\n'
      '      body: ${_short(e.response?.data)}',
    );
  }

  static String _short(dynamic body) {
    final s = body?.toString() ?? 'null';
    return s.length > _maxBody ? '${s.substring(0, _maxBody)}…' : s;
  }

  
  static void etag(
    String tag, {
    int? status,
    String? requestIfNoneMatch,
    String? responseEtag,
    bool fromCache = false,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      '[ETAG] $tag\n'
      '      status: $status\n'
      '      If-None-Match (sent): ${requestIfNoneMatch ?? '-'}\n'
      '      ETag (response): ${responseEtag ?? '-'}\n'
      '      fromCache: $fromCache',
    );
  }

}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('[BLOC] ${bloc.runtimeType}: '
          '${change.currentState.runtimeType} → ${change.nextState.runtimeType}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.error('${bloc.runtimeType}', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  
}