
import 'package:dio/dio.dart';
import 'package:app_development_project/constants/api_constants.dart';
import 'package:app_development_project/data/models/auth/login_response_model.dart';
import 'package:app_development_project/data/models/logout_response_model.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/network/app_logger.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  // Future<LoginResponseModel> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   final response = await dio.post(
  //     ApiConstants.login,
  //     data: {
  //       'email': email,
  //       'password': password,
  //     },
  //   );

  //   return LoginResponseModel.fromJson(response.data);
  // }

  Future<LoginResponseModel> login({
  required String email,
  required String password,
}) async {
  const tag = 'AuthService.login';

  try {
    AppLogger.request(tag, 'POST', ApiConstants.login);

    final response = await dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    AppLogger.response(tag, response.statusCode, response.data);

    final root = response.data;
    if (root is! Map) {
      throw ApiException('Unexpected response from server.');
    }

    final map = Map<String, dynamic>.from(root);
    final code = (map['code'] as num?)?.toInt() ?? response.statusCode ?? 200;

    if (code >= 400) {
      throw ApiException.fromResponse(code, map);
    }

    return LoginResponseModel.fromJson(map);
  } on ApiException catch (e) {
    AppLogger.error(tag, e);
    rethrow;
  } on DioException catch (e) {
    AppLogger.dio(tag, e);
    throw ApiException.fromDio(e);
  } catch (e, st) {
    AppLogger.error(tag, e, st);
    throw ApiException('Unexpected response format.');
  }
}

  Future<LogoutResponseModel> logout() async {
    const tag = 'AuthService.logout';

    try {
      AppLogger.request(tag, 'POST', ApiConstants.logout);

      final response = await dio.post(ApiConstants.logout);

      AppLogger.response(tag, response.statusCode, response.data);

      final root = response.data;
      if (root is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      final code =
          (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;

      if (code >= 400) {
        throw ApiException.fromResponse(code, root);
      }

      return LogoutResponseModel.fromJson(Map<String, dynamic>.from(root));
    } on ApiException catch (e) {
      AppLogger.error(tag, e);
      rethrow;
    } on DioException catch (e) {
      AppLogger.dio(tag, e);
      throw ApiException.fromDio(e);
    } catch (e, st) {
      AppLogger.error(tag, e, st);
      throw ApiException('Unexpected response format.');
    }
  }
}
