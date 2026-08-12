part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoadingStatus extends HomeState {}

final class HomeClientDataLoadedSuccessStatus extends HomeState {
  final ClientModel clientModel;

  HomeClientDataLoadedSuccessStatus({required this.clientModel});
}

final class HomeErrorStatus extends HomeState {
  final String errorMessage;

  HomeErrorStatus({required this.errorMessage});
}
