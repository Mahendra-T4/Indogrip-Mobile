import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:indo_mobile/core/database/hive_keys.dart';
import 'package:indo_mobile/core/database/hive_service.dart';
import 'package:indo_mobile/core/service/dio_service.dart';
import 'package:indo_mobile/features/auth/model/auth_login_model.dart';
import 'package:indo_mobile/features/auth/repositories/auth_repo.dart';

class AuthManagerRepository implements AuthRepository {
  @override
  Future<AuthLoginModel> indoGripLogin({
    required String uEmail,
    required String uPassword,
  }) async {
    AuthLoginModel model = AuthLoginModel();
    try {
      final formData = FormData.fromMap({
        'activity': 'login',
        'uEmail': uEmail,
        'uPassword': uPassword,
      });
      final response = await DioService.postApiCall(data: formData);

      if (response.statusCode == 200) {
        model = AuthLoginModel.fromJson(response.data);
        if (model.status == 1) {
          await HiveService.setter(
            key: HiveKeys.fNameKey,
            value: model.record!.userFirstName.toString(),
          );

          await HiveService.setter(
            key: HiveKeys.lNameKey,
            value: model.record!.userLastName.toString(),
          );

          await HiveService.setter(
            key: HiveKeys.emailKey,
            value: model.record!.userEmailID.toString(),
          );

          await HiveService.setter(
            key: HiveKeys.personalEmailKey,
            value: model.record!.userPersonalEmailID.toString(),
          );

          await HiveService.setter(
            key: HiveKeys.mobileKey,
            value: model.record!.userMobileNumber.toString(),
          );

          await HiveService.setter(
            key: HiveKeys.alternateMobileKey,
            value: model.record!.userAlternateNumber.toString(),
          );
          await HiveService.setter(
            key: HiveKeys.role,
            value: model.record!.userRole.toString(),
          );
          await HiveService.setter(
            key: HiveKeys.panels,
            value: model.record!.userAssignedPanels.toString(),
          );

          await HiveService.setter(
            key: HiveKeys.userImage,
            value: model.record!.userImage.toString(),
          );

          await HiveService.setter(
            key: HiveKeys.userIDKey,
            value: model.record!.userKey.toString(),
          );

          await HiveService.setter(key: HiveKeys.kIsLoggedIn, value: true);

          developer.log('model Logged In: ${model.message}');
        } else {
          developer.log('Logged Failed: ${model.message}');
        }
        developer.log(formData.fields.toString(), name: 'Login Param');
        developer.log(model.message.toString(), name: 'Login Response');
      } else {
        developer.log('Failed to login', name: 'Login Failed Response');
      }
    } catch (e) {
      developer.log(e.toString(), name: 'Login Error');
    }
    return model;
  }
}
