part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthIndoGripMobileLoginEvent extends AuthEvent {
  final String uEmail;
  final String uPassword;

  AuthIndoGripMobileLoginEvent({required this.uEmail, required this.uPassword});
}
