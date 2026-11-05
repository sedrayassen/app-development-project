import 'package:app_development_project/features/auth/data/datasources/token_storage.dart';
import 'package:app_development_project/data/services/auth_service.dart';
import 'package:app_development_project/data/models/auth/login_response_model.dart';
import 'package:app_development_project/data/models/logout_response_model.dart';
import 'package:app_development_project/data/network/api_exception.dart';

class AuthRepository {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthRepository({
    required this.authService,
    required this.tokenStorage,
  });

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final result = await authService.login(
      email: email,
      password: password,
    );

    await tokenStorage.saveToken(result.accessToken);

    return result;
  }

  Future<LogoutResponseModel> logout() async {
    try {
      final result = await authService.logout();
      await tokenStorage.deleteToken();
      return result;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await tokenStorage.deleteToken();
      }
      rethrow;
    }
  }

  Future<void> clearSession() async {
    await tokenStorage.deleteToken();
  }

  Future<String?> getSavedToken() {
    return tokenStorage.getToken();
  }
}