import 'package:snapgo/models/spot_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadingMore extends HomeState {
  final List<SpotEntity> spots;
  final String currentTab;
  
  HomeLoadingMore({
    required this.spots,
    required this.currentTab,
  });
}

class HomeLoaded extends HomeState {
  final List<SpotEntity> spots;
  final String currentTab;
  final bool hasReachedMax;
  
  HomeLoaded({
    required this.spots,
    required this.currentTab,
    required this.hasReachedMax,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}