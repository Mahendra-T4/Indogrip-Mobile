import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indo_mobile/core/config/env_config.dart';
import 'package:indo_mobile/core/database/hive%20initialize.dart';
import 'package:indo_mobile/core/database/hive_service.dart';
import 'package:indo_mobile/core/di/sl.dart';
import 'package:indo_mobile/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvConfig.init();
  await HiveService.init();
  HiveInitialize.init();
  await ServiceLocator().init();
  runApp(ProviderScope(child: App()));
}




      
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      title: 'Indogrip App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
    );
  }
}
