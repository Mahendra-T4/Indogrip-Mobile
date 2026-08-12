import 'package:get_it/get_it.dart';
import 'package:indo_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:indo_mobile/features/auth/repositories/auth_manager_repo.dart';
import 'package:indo_mobile/features/auth/repositories/auth_repo.dart';
import 'package:indo_mobile/features/home/bloc/home_bloc.dart';
import 'package:indo_mobile/features/home/repositories/home_repo.dart';
import 'package:indo_mobile/features/scanner/bloc/round_details_bloc.dart';
import 'package:indo_mobile/features/scanner/repositories/round_details_bloc.dart';

GetIt sl = GetIt.instance;

class ServiceLocator {
  Future<void> init() async {
    initRepository();
    initBloc();
  }

  Future<void> initRepository() async {
    sl.registerLazySingleton(() => AuthManagerRepository());

    sl.registerLazySingleton<AuthRepository>(() => sl<AuthManagerRepository>());
    sl.registerLazySingleton<HomeRepository>(() => HomeRepository());

    sl.registerLazySingleton<RoundDetailsRepository>(
      () => RoundDetailsRepository(),
    );
  }

  Future<void> initBloc() async {
    sl.registerLazySingleton(() => AuthBloc(repository: sl<AuthRepository>()));
    sl.registerLazySingleton(() => HomeBloc(repository: sl<HomeRepository>()));
    sl.registerLazySingleton(
      () => RoundDetailsBloc(repository: sl<RoundDetailsRepository>()),
    );
  }
}
