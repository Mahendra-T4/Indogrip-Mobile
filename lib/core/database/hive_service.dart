import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:indo_mobile/core/database/hive_keys.dart';
import 'package:indo_mobile/features/auth/login/login.dart';

class HiveService {
  static const String indogripBox = 'myBox';
  static Box<dynamic>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(indogripBox);
  }

  static Future<void> setter({
    required String key,
    required dynamic value,
  }) async {
    await _box?.put(key, value);
  }

  /// Delete a value by key
  static Future<void> delete(String key) async {
    await _box?.delete(key);
  }

  static dynamic getter({required String key}) {
    return _box?.get(key);
  }

  // /// Check if user is logged in
  // static bool get isLoggedIn {
  //   final value = getter(key: HiveKeys.kIsLoggedIn) ?? false;
  //   print('DEBUG: HiveService.isLoggedIn = $value');
  //   print('DEBUG: Hive box contents: ${_box?.toMap()}');
  //   return value;
  // }

  /// Set user as logged in
  static Future<void> setLoggedIn(bool value) async {
    await setter(key: HiveKeys.kIsLoggedIn, value: value);
  }

  /// Get user ID
  static String? getUserId() => getter(key: HiveKeys.userIDKey);

  /// Save login data to Hive
  static Future<void> saveLoginData({
    required String? userFirstName,
    required String? userLastName,
    required String? userEmailID,
    required String? userMobileNumber,
    required String? userAlternateNumber,
    required String? userPersonalEmailID,
    required int? userRole,
    required String? userAssignedPanels,
    required String? userImage,
    required String? userKey,
  }) async {
    await setter(key: HiveKeys.fNameKey, value: userFirstName ?? '');
    await setter(key: HiveKeys.lNameKey, value: userLastName ?? '');
    await setter(key: HiveKeys.emailKey, value: userEmailID ?? '');
    await setter(key: HiveKeys.mobileKey, value: userMobileNumber ?? '');
    await setter(
      key: HiveKeys.alternateMobileKey,
      value: userAlternateNumber ?? '',
    );
    await setter(
      key: HiveKeys.personalEmailKey,
      value: userPersonalEmailID ?? '',
    );
    await setter(key: HiveKeys.role, value: userRole?.toString() ?? '');
    await setter(key: HiveKeys.panels, value: userAssignedPanels ?? '');
    await setter(key: HiveKeys.userImage, value: userImage ?? '');
    await setter(key: HiveKeys.userKeyKey, value: userKey ?? '');
    await setter(key: HiveKeys.kIsLoggedIn, value: true);
  }

  /// Get user Email

  static String? getUserEmail() => getter(key: HiveKeys.emailKey);

  /// Get user name
  static String? getFName() => getter(key: HiveKeys.fNameKey);

  /// Get user last name
  static String? getLName() => getter(key: HiveKeys.lNameKey);

  /// Get user mobile number
  static String? getMobile() => getter(key: HiveKeys.mobileKey);

  static bool isLoggedInUser() => getter(key: HiveKeys.kIsLoggedIn) ?? false;

  ///Get alternate mobile number
  static String? getAlternateMobile() =>
      getter(key: HiveKeys.alternateMobileKey);

  /// Get user email
  static String? getEmail() => getter(key: HiveKeys.emailKey);

  /// Get user role
  static String? getRole() => getter(key: HiveKeys.role);

  static String? userImage() => getter(key: HiveKeys.userImage);

  static Future<void> logout(BuildContext context) async {
    // Clear all user data
    await _box?.clear();

    // Re-initialize the box
    await _box?.close();
    _box = await Hive.openBox(indogripBox);

    // Set logged in to false
    await setLoggedIn(false);

    // Navigate to login
    context.goNamed(IndoGripLoginView.routeName);
  }

  // /// Clear all data
  // static Future<void> clearAll() async {
  //   await _box?.clear();
  // }
}
