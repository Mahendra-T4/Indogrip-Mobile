import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:indo_mobile/core/database/hive_service.dart';
import 'package:indo_mobile/core/service/dio_service.dart';
import 'package:indo_mobile/features/scanner/model/challan_details_model.dart';
import 'package:indo_mobile/features/scanner/model/round_details.dart';


class RoundDetailsRepository {
  Future<RoundDetails> fetchRoundDetails({required String batchCode}) async {
    RoundDetails model = RoundDetails();
    try {
      final response = await DioService.postApiCall(
        data: FormData.fromMap({
          'activity': 'round-details',
          'userKey': HiveService.getUserId(),
          'batchCode': batchCode,
        }),
      );
      if (response.statusCode == 200) {
        model = RoundDetails.fromJson(response.data);
        developer.log(
          response.data.toString(),
          name: ' Round Details Response',
        );
      } else {
        developer.log(
          'Failed to fetch round details',
          name: ' Round Details Failed Response',
        );
      }
    } catch (e) {
      developer.log(e.toString(), name: ' Round Details  Error');
    }
    return model;
  }

  Future<ChallanDetailsResponse> submitBatchInfo(
    List<String> batchCodes,
    List<String> batchQty,
    String unitIndex,
    String clientKey,
  ) async {
    ChallanDetailsResponse submitModel = ChallanDetailsResponse();
    try {
      final formData = FormData.fromMap({
        'activity': 'batch-information',
        'userKey': HiveService.getUserId(),
        'batchCode': batchCodes.join(','),
        'clientKey': clientKey,
        'batchQty': batchQty.join(','),
        'unitIndex': unitIndex,
      });
      final response = await DioService.postApiCall(data: formData);
      if (response.statusCode == 200) {
        submitModel = ChallanDetailsResponse.fromJson(response.data);
        developer.log(formData.fields.toString(), name: 'Form Data Submitted');

        developer.log(
          response.data.toString(),
          name: ' Submit Batch Info API Response',
        );
      } else {
        developer.log(
          'Failed to submit batch info',
          name: ' Submit Batch Info Failed Response',
        );
      }
    } catch (e) {
      developer.log(e.toString(), name: ' Submit Batch Info Error');
      rethrow;
    }
    return submitModel;
  }
}
