import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Default values if .env is not loaded

  static String get indoGripMobileUrl =>
      dotenv.env['INDOGRIP_MOBILE_BASE_URL']!;

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      developer.log('Environment loaded successfully', name: 'EnvConfig');
      developer.log('Base URL: $indoGripMobileUrl', name: 'EnvConfig');
    } catch (e) {
      developer.log(
        'Error loading .env file, using default values',
        name: 'EnvConfig',
        error: e,
      );
    }
  }
}
