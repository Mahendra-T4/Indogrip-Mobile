part of 'round_details_bloc.dart';

@immutable
sealed class RoundDetailsEvent {}

final class FetchRoundDetailsEvent extends RoundDetailsEvent {
  final String batchCode;

  FetchRoundDetailsEvent({required this.batchCode});
}

final class FetchRoundScannedDataEvent extends RoundDetailsEvent {}

final class SubmitRoundScannedDataEvent extends RoundDetailsEvent {
  final List<String> batchCodes;
  final List<String> batchQty;
  final String unitIndex;
  final String clientKey;

  SubmitRoundScannedDataEvent({
    required this.batchCodes,
    required this.batchQty,
    required this.unitIndex,
    required this.clientKey,
  });
}
