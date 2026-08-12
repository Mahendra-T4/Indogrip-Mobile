part of 'round_details_bloc.dart';

@immutable
sealed class RoundDetailsState {}

final class RoundDetailsInitial extends RoundDetailsState {}

final class RoundDetailsLoadingStatus extends RoundDetailsState {}

final class RoundDetailsLoadedSuccessStatus extends RoundDetailsState {
  final RoundDetails dataModel;

  RoundDetailsLoadedSuccessStatus({required this.dataModel});
}

final class RoundDetailsLoadedFailureStatus extends RoundDetailsState {
  final String errorMessage;

  RoundDetailsLoadedFailureStatus({required this.errorMessage});
}

//! States for scanned data

final class RoundDetailsScannedDataLoadedStatus extends RoundDetailsState {
  final RoundDataModel roundData;

  RoundDetailsScannedDataLoadedStatus({required this.roundData});
}

final class RoundDetailsScannedDataFailureStatus extends RoundDetailsState {
  final String errorMessage;

  RoundDetailsScannedDataFailureStatus({required this.errorMessage});
}

final class SubmitRoundScannedDataSuccessStatus extends RoundDetailsState {
  final ChallanDetailsResponse model;

  SubmitRoundScannedDataSuccessStatus({required this.model});
}

final class SubmitRoundScannedDataFailureStatus extends RoundDetailsState {
  final String errorMessage;

  SubmitRoundScannedDataFailureStatus({required this.errorMessage});
}
