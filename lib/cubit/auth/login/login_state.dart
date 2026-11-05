import 'package:app_development_project/data/models/auth/login_response_model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponseModel loginResponse;

  LoginSuccess(this.loginResponse);
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}