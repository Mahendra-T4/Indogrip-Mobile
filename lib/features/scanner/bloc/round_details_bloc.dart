import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:indo_mobile/features/scanner/model/challan_details_model.dart';
import 'package:indo_mobile/features/scanner/model/round_data_model.dart';
import 'package:indo_mobile/features/scanner/model/round_details.dart';
import 'package:indo_mobile/features/scanner/model/submit_batch_model.dart';
import 'package:indo_mobile/features/scanner/repositories/round_details_bloc.dart';
import 'package:meta/meta.dart';

part 'round_details_event.dart';
part 'round_details_state.dart';

class RoundDetailsBloc extends Bloc<RoundDetailsEvent, RoundDetailsState> {
  final RoundDetailsRepository repository;
  RoundDetailsBloc({required this.repository}) : super(RoundDetailsInitial()) {
    on<FetchRoundDetailsEvent>(_fetchRoundDetailsEvent);
    on<FetchRoundScannedDataEvent>(_fetchRoundScannedDataEvent);
    on<SubmitRoundScannedDataEvent>(_submitRoundScannedDataEvent);
  }

  FutureOr<void> _fetchRoundDetailsEvent(
    FetchRoundDetailsEvent event,
    Emitter<RoundDetailsState> emit,
  ) async {
    emit(RoundDetailsLoadingStatus());
    try {
      final RoundDetails dataModel = await repository.fetchRoundDetails(
        batchCode: event.batchCode,
      );
      emit(RoundDetailsLoadedSuccessStatus(dataModel: dataModel));
    } catch (e) {
      emit(RoundDetailsLoadedFailureStatus(errorMessage: e.toString()));
    }
  }

  FutureOr<void> _fetchRoundScannedDataEvent(
    FetchRoundScannedDataEvent event,
    Emitter<RoundDetailsState> emit,
  ) {
    emit(RoundDetailsLoadingStatus());
    try {} catch (e) {
      print(e);
    }
  }

  FutureOr<void> _submitRoundScannedDataEvent(
    SubmitRoundScannedDataEvent event,
    Emitter<RoundDetailsState> emit,
  ) async {
    emit(RoundDetailsLoadingStatus());
    try {
      final batchCodes = await repository.submitBatchInfo(
        event.batchCodes,
        event.batchQty,
        event.unitIndex,
        event.clientKey,
      );
      emit(SubmitRoundScannedDataSuccessStatus(model: batchCodes));
    } catch (e) {
      emit(SubmitRoundScannedDataFailureStatus(errorMessage: e.toString()));
    }
  }
}
