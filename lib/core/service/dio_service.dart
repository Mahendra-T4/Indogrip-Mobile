import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:indo_mobile/core/config/env_config.dart';

class DioService {
  static final Dio dio = _initDio();

  static Dio _initDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Configure HTTP client adapter to handle certificate verification
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // For development: ignore certificate verification errors
        // WARNING: Never use this in production!
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              log(
                'Certificate verification failed for $host. Using insecure connection.',
              );
              return true; // Accept all certificates (development only)
            };
        return client;
      },
    );

    // Initialize interceptors
    _initInterceptors(dio);

    return dio;
  }

  static final url = EnvConfig.indoGripMobileUrl;

  // simple retry configuration
  static const int _maxRetries = 2;

  // initialize interceptors
  static void _initInterceptors(Dio dio) {
    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          try {
            final req = error.requestOptions;
            final currentRetries = (req.extra['retries'] ?? 0) as int;

            final shouldRetry =
                (error.error is SocketException) ||
                error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.unknown ||
                error.type == DioExceptionType.connectionTimeout;

            if (shouldRetry && currentRetries < _maxRetries) {
              req.extra['retries'] = currentRetries + 1;
              // small backoff
              await Future.delayed(
                Duration(milliseconds: 300 * (currentRetries + 1)),
              );
              try {
                final response = await dio.fetch(req);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          } catch (_) {
            // fall through to next
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ensure interceptors are registered
  // ignore: unused_field
  static final bool _interceptorsInitialized = (() {
    _initInterceptors(dio);
    return true;
  })();

  static Future<Response> postApiCall({data}) async {
    try {
      final response = await dio.post(url, data: data);
      return response;
    } on DioException catch (e) {
      // rethrow with more context if needed
      log(e.toString());
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
