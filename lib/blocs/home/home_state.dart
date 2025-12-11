import 'package:snapgo/models/spot_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<SpotEntity> spots;
  final String currentTab;
  
  HomeLoaded(this.spots, this.currentTab);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}