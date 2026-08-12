part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class FetchClientDataEvent extends HomeEvent {
  final String filterBy;
  final String keyword;

  FetchClientDataEvent({required this.filterBy, required this.keyword});
}
