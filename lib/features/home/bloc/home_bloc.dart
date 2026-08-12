import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:indo_mobile/features/home/model/client_model.dart';
import 'package:indo_mobile/features/home/repositories/home_repo.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<FetchClientDataEvent>(fetchClientDataEvent);
  }

  FutureOr<void> fetchClientDataEvent(
    FetchClientDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingStatus());
    try {
      final clientModel = await HomeRepository.fetchClientData(
        filterBy: event.filterBy,
        keyword: event.keyword,
      );
      emit(HomeClientDataLoadedSuccessStatus(clientModel: clientModel));
    } catch (e) {
      emit(HomeErrorStatus(errorMessage: e.toString()));
    }
  }
}
