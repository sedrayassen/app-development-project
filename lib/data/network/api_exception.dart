import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  final Map<String, List<String>> fieldErrors;

  final bool isNetwork;

  ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
    this.isNetwork = false,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidation => statusCode == 422;
  bool get isServiceUnavailable => statusCode == 503;
  bool get isServerError => (statusCode ?? 0) >= 500;

 factory ApiException.fromResponse(int? status, dynamic body) {
  final serverMessage = body is Map ? body['message']?.toString() : null;

  final Map<String, List<String>> fieldErrors =
      status == 422 ? _parseFieldErrors(body) : const <String, List<String>>{};

  switch (status) {
    case 401:
      return ApiException(
        serverMessage ?? 'Unauthenticated. Please log in again.',
        statusCode: 401,
      );
    case 403:
      return ApiException(
        serverMessage ?? 'You are not authorized to perform this action.',
        statusCode: 403,
      );
    case 404:
      return ApiException(serverMessage ?? 'Not found.', statusCode: 404);
    case 409:
      return ApiException(
        serverMessage ?? 'The request conflicts with the current state.',
        statusCode: 409,
      );
    case 422:
      final first = fieldErrors.values.isNotEmpty &&
              fieldErrors.values.first.isNotEmpty
          ? fieldErrors.values.first.first
          : null;
      return ApiException(
        first ?? serverMessage ?? 'Invalid data. Please check your input.',
        statusCode: 422,
        fieldErrors: fieldErrors,
      );
    case 503:
      return ApiException(
        serverMessage ?? 'Service temporarily unavailable.',
        statusCode: 503,
      );
      case 429:
  return ApiException(
    serverMessage ?? 'Too many requests. Please try again later.',
    statusCode: 429,
  );
    default:
      return ApiException(
        serverMessage ?? 'Something went wrong. Please try again.',
        statusCode: status,
      );
  }
}

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timed out. Please try again.',
          isNetwork: true,
         );
      // case DioExceptionType.connectionError:
      //   return ApiException('No internet connection.', isNetwork: true);
      case DioExceptionType.connectionError:
  return ApiException(
    'Cannot reach the server (${e.requestOptions.uri.host}). '
    'Check that the backend is running and the base URL is correct.',
    isNetwork: true,
  );
      default:
        break;
    }

    return ApiException.fromResponse(e.response?.statusCode, e.response?.data);
  }

  static Map<String, List<String>> _parseFieldErrors(dynamic body) {
    if (body is! Map) return const {};

    final source = body['errors'] is Map
        ? body['errors']
        : (body['data'] is Map ? body['data'] : null);
    if (source is! Map) return const {};

    final out = <String, List<String>>{};
    source.forEach((key, value) {
      if (value is List) {
        out['$key'] = value.map((e) => '$e').toList();
      } else if (value != null) {
        out['$key'] = ['$value'];
      }
    });
    return out;
  }

  @override
  String toString() => message;
}