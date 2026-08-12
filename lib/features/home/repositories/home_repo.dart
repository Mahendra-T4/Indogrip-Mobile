import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:indo_mobile/core/database/hive_service.dart';
import 'package:indo_mobile/core/service/dio_service.dart';
import 'package:indo_mobile/features/home/model/client_model.dart';

class HomeRepository {
  static Future<ClientModel> fetchClientData({
    required String filterBy,
    required String keyword,
  }) async {
    ClientModel clientModel = ClientModel();
    try {
      final response = await DioService.postApiCall(
        data: FormData.fromMap({
          'activity': 'view-client',
          'userKey': HiveService.getUserId(),
          'filterBy': filterBy,
          'keyword': keyword,
          'sortBy': '500',
        }),
      );

      if (response.statusCode == 200) {
        clientModel = ClientModel.fromJson(response.data);
        developer.log(name: 'Client Data:', response.data);
      } else {
        developer.log(
          name: 'Failed to fetching client data:',
          response.statusMessage ?? 'Unknown error',
        );
      }
    } catch (e) {
      developer.log(name: 'Error fetching client data:', e.toString());
    }
    return clientModel;
  }
}
