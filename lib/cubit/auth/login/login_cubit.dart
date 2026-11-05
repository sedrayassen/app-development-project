// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:app_development_project/cubit/auth/login/login_state.dart';
// import 'package:app_development_project/data/repository/auth_repository.dart';

// class LoginCubit extends Cubit<LoginState> {
//   final AuthRepository authRepository;

//   LoginCubit(this.authRepository) : super(LoginInitial());

//   Future<void> login({
//     required String email,
//     required String password,
//   }) async {
//     if (email.trim().isEmpty || password.isEmpty) {
//       emit(LoginFailure('Please enter email and password.'));
//       return;
//     }

//     emit(LoginLoading());

//     try {
//       final result = await authRepository.login(
//         email: email.trim(),
//         password: password,
//       );

//       emit(LoginSuccess(result));
//     } catch (e) {
//       emit(
//         LoginFailure(
//           e.toString().replaceFirst('Exception: ', ''),
//         ),
//       );
//     }
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/auth/login/login_state.dart';
import 'package:app_development_project/data/repository/auth_repository.dart';
import 'package:app_development_project/data/network/api_exception.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit(this.authRepository) : super(LoginInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      emit(LoginFailure('Please enter email and password.'));
      return;
    }

    emit(LoginLoading());

    try {
      final result = await authRepository.login(
        email: email.trim(),
        password: password,
      );

      emit(LoginSuccess(result));
    } on ApiException catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(LoginFailure('Something went wrong. Please try again.'));
    }
  }
}