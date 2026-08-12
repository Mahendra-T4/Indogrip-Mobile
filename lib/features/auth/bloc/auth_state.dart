part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoadingStatus extends AuthState {}

final class AuthIndoGripMobileLoginLoadedSuccessStatus extends AuthState {
  final AuthLoginModel model;

  AuthIndoGripMobileLoginLoadedSuccessStatus({required this.model});
}

final class AuthIndoGripLoginFailedErrorStatus extends AuthState {
  final String error;

  AuthIndoGripLoginFailedErrorStatus({required this.error});
}
