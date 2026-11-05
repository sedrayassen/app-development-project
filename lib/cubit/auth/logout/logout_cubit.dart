import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/auth/logout/logout_state.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/network/app_logger.dart';
import 'package:app_development_project/data/repository/auth_repository.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final AuthRepository repository;

  LogoutCubit(this.repository) : super(LogoutInitial());

  static const _tag = 'LogoutCubit';

  bool _busy = false;

  Future<void> logout() async {
    if (_busy) return; 
    _busy = true;
    emit(LogoutLoading());

    try {
      final result = await repository.logout();
      if (isClosed) return;
      emit(LogoutSuccess(result.message));
    } on ApiException catch (e, st) {
      AppLogger.error('$_tag.logout status=${e.statusCode}', e, st);
      if (isClosed) return;

      if (e.isUnauthorized) {
        emit(LogoutSessionExpired(e.message));
      } else {
        emit(LogoutFailure(e.message, isNetwork: e.isNetwork));
      }
    } catch (e, st) {
      AppLogger.error('$_tag.logout unexpected', e, st);
      if (isClosed) return;
      emit(LogoutFailure('Unexpected error. Please try again.'));
    } finally {
      _busy = false;
    }
  }

  Future<void> forceLogout() async {
    if (_busy) return;
    _busy = true;
    try {
      await repository.clearSession();
      if (isClosed) return;
      emit(LogoutSuccess('Logged out locally.'));
    } catch (e, st) {
      AppLogger.error('$_tag.forceLogout', e, st);
      if (isClosed) return;
      emit(LogoutFailure('Could not clear the session.'));
    } finally {
      _busy = false;
    }
  }
}