import 'package:hive/hive.dart';
import 'package:indo_mobile/features/scanner/model/round_data_model.dart';
import 'package:path_provider/path_provider.dart';

class HiveInitialize {
  static final roundBox = 'round_data_box';

  static Future<void> init() async {
    var directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    Hive.registerAdapter(RoundDataModelAdapter());
    await Hive.openBox<RoundDataModel>(roundBox);
  }
}
