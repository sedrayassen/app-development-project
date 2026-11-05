abstract class LogoutState {}

class LogoutInitial extends LogoutState {}

class LogoutLoading extends LogoutState {}

/// 200 
class LogoutSuccess extends LogoutState {
  final String message;
  LogoutSuccess(this.message);
}

/// 401
class LogoutSessionExpired extends LogoutState {
  final String message;
  LogoutSessionExpired(this.message);
}

class LogoutFailure extends LogoutState {
  final String message;
  final bool isNetwork;
  LogoutFailure(this.message, {this.isNetwork = false});
}