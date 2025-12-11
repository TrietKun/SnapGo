import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/home/home_event.dart';
import 'package:snapgo/blocs/home/home_state.dart';
import 'package:snapgo/models/mock_data.dart';
import 'package:snapgo/models/spot_entity.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadSpotsEvent>(_onLoadSpots);
    on<RefreshSpotsEvent>(_onRefreshSpots);
  }

  Future<void> _onLoadSpots(
      LoadSpotsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await Future.delayed(Duration(milliseconds: 500));

    try {
      final spots = _getSpotsByTab(event.tab);
      emit(HomeLoaded(spots, event.tab));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshSpots(
      RefreshSpotsEvent event, Emitter<HomeState> emit) async {
    try {
      final spots = _getSpotsByTab(event.tab);
      emit(HomeLoaded(spots, event.tab));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  List<SpotEntity> _getSpotsByTab(String tab) {
    final allSpots = MockData.getSpots();
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));

    switch (tab) {
      case 'trending':
        return allSpots
            .where((spot) => spot.createdAt.isAfter(oneWeekAgo))
            .toList()
          ..sort((a, b) => b.trendingScore.compareTo(a.trendingScore));

      case 'newest':
        return allSpots
            .where((spot) => spot.createdAt.isAfter(oneWeekAgo))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      case 'popular':
        return allSpots
            .where((spot) => spot.createdAt.isAfter(oneWeekAgo))
            .toList()
          ..sort((a, b) => b.checkInCount.compareTo(a.checkInCount));

      default:
        return allSpots;
    }
  }
}
