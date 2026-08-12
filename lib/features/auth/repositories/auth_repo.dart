import 'package:indo_mobile/features/auth/model/auth_login_model.dart';

abstract class AuthRepository {
  Future<AuthLoginModel> indoGripLogin({
    required String uEmail,
    required String uPassword,
  });
}
