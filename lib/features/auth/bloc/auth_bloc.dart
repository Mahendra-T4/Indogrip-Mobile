import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:indo_mobile/core/database/hive_service.dart';
import 'package:indo_mobile/features/auth/model/auth_login_model.dart';
import 'package:indo_mobile/features/auth/repositories/auth_repo.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthIndoGripMobileLoginEvent>(authIndoGripMobileLoginEvent);
  }

  FutureOr<void> authIndoGripMobileLoginEvent(
    AuthIndoGripMobileLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingStatus());
    try {
      final login = await repository.indoGripLogin(
        uEmail: event.uEmail,
        uPassword: event.uPassword,
      );

      // Save login data to Hive if login is successful
      if (login.status == 1 && login.record != null) {
        print('DEBUG: AuthBloc - Saving login data to Hive');
        print('DEBUG: AuthBloc - User email: ${login.record?.userEmailID}');
        await HiveService.saveLoginData(
          userFirstName: login.record?.userFirstName,
          userLastName: login.record?.userLastName,
          userEmailID: login.record?.userEmailID,
          userMobileNumber: login.record?.userMobileNumber,
          userAlternateNumber: login.record?.userAlternateNumber,
          userPersonalEmailID: login.record?.userPersonalEmailID,
          userRole: login.record?.userRole,
          userAssignedPanels: login.record?.userAssignedPanels,
          userImage: login.record?.userImage,
          userKey: login.record?.userKey,
        );
        print('DEBUG: AuthBloc - Login data saved');
      } else {
        print('DEBUG: AuthBloc - Login failed or no record received');
      }

      emit(AuthIndoGripMobileLoginLoadedSuccessStatus(model: login));
    } catch (e) {
      emit(AuthIndoGripLoginFailedErrorStatus(error: e.toString()));
    }
  }
}
