import 'package:hive/hive.dart';
import 'package:indo_mobile/core/database/hive%20initialize.dart';
import 'package:indo_mobile/features/scanner/model/round_data_model.dart';

class Boxes {
  static Box<RoundDataModel> getData() =>
      Hive.box<RoundDataModel>(HiveInitialize.roundBox);
}
