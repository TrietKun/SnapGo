import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/home/home_event.dart';
import 'package:snapgo/blocs/home/home_state.dart';
import 'package:snapgo/models/spot_entity.dart';
import 'package:snapgo/repositories/spot_repository.dart/spot_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SpotRepository repository;

  // Cache theo từng tab
  final Map<String, List<SpotEntity>> _cache = {};

  // Track trang hiện tại của mỗi tab
  final Map<String, int> _currentPage = {};

  // Track xem tab nào đã load hết data chưa
  final Map<String, bool> _hasReachedMax = {};

  // Page size
  static const int _pageSize = 1;

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<LoadSpotsEvent>(_onLoadSpots);
    on<LoadMoreSpotsEvent>(_onLoadMoreSpots);
    on<RefreshSpotsEvent>(_onRefreshSpots);
  }

  // Load lần đầu hoặc khi chuyển tab
  Future<void> _onLoadSpots(
    LoadSpotsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Nếu đã có cache → emit ngay không cần loading
    if (_cache.containsKey(event.tab) && _cache[event.tab]!.isNotEmpty) {
      emit(HomeLoaded(
        spots: _cache[event.tab]!,
        currentTab: event.tab,
        hasReachedMax: _hasReachedMax[event.tab] ?? false,
      ));
      return;
    }

    // Chưa có cache → load mới
    emit(HomeLoading());

    try {
      final spots = await repository.getSpots(
        event.tab,
        page: 1,
        pageSize: _pageSize,
      );

      // Lưu vào cache
      _cache[event.tab] = spots;
      _currentPage[event.tab] = 1;
      _hasReachedMax[event.tab] = spots.length < _pageSize;

      emit(HomeLoaded(
        spots: spots,
        currentTab: event.tab,
        hasReachedMax: _hasReachedMax[event.tab]!,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // Load more (infinite scroll)
  Future<void> _onLoadMoreSpots(
    LoadMoreSpotsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Nếu đã load hết → không làm gì
    if (_hasReachedMax[event.tab] == true) return;

    // Nếu đang loading → không làm gì (tránh duplicate request)
    if (state is HomeLoadingMore) return;

    final currentSpots = _cache[event.tab] ?? [];
    final currentPage = _currentPage[event.tab] ?? 1;

    emit(HomeLoadingMore(
      spots: currentSpots,
      currentTab: event.tab,
    ));

    try {
      final newSpots = await repository.getSpots(
        event.tab,
        page: currentPage + 1,
        pageSize: _pageSize,
      );

      // Merge với cache cũ
      final updatedSpots = [...currentSpots, ...newSpots];
      _cache[event.tab] = updatedSpots;
      _currentPage[event.tab] = currentPage + 1;
      _hasReachedMax[event.tab] = newSpots.length < _pageSize;

      emit(HomeLoaded(
        spots: updatedSpots,
        currentTab: event.tab,
        hasReachedMax: _hasReachedMax[event.tab]!,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // Refresh (pull to refresh)
  Future<void> _onRefreshSpots(
    RefreshSpotsEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final spots = await repository.refresh(
        event.tab,
        page: 1,
        pageSize: _pageSize,
      );

      // Clear cache và reset
      _cache[event.tab] = spots;
      _currentPage[event.tab] = 1;
      _hasReachedMax[event.tab] = spots.length < _pageSize;

      emit(HomeLoaded(
        spots: spots,
        currentTab: event.tab,
        hasReachedMax: _hasReachedMax[event.tab]!,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
