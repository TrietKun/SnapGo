import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/home/home_event.dart';
import 'package:snapgo/blocs/home/home_state.dart';
import 'package:snapgo/models/spot_entity.dart';
import 'package:snapgo/repositories/spot_repositories/spot_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SpotRepository repository;
  // ❌ XÓA dòng này: final BuildContext context;

  final Map<String, Map<String, List<SpotEntity>>> _cache = {};
  final Map<String, Map<String, int>> _currentPage = {};
  final Map<String, Map<String, bool>> _hasReachedMax = {};

  static const int _pageSize = 10;

  // ✅ Không nhận context nữa
  HomeBloc(this.repository) : super(HomeInitial()) {
    on<LoadSpotsEvent>(_onLoadSpots);
    on<LoadMoreSpotsEvent>(_onLoadMoreSpots);
    on<RefreshSpotsEvent>(_onRefreshSpots);
    on<LocaleChangedEvent>(_onLocaleChanged);
  }

  Future<void> _onLoadSpots(
    LoadSpotsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // ✅ Lấy locale từ event
    final locale = event.locale;

    // Check cache theo tab + locale
    if (_cache[event.tab]?[locale]?.isNotEmpty ?? false) {
      emit(HomeLoaded(
        spots: _cache[event.tab]![locale]!,
        currentTab: event.tab,
        hasReachedMax: _hasReachedMax[event.tab]?[locale] ?? false,
      ));
      return;
    }

    emit(HomeLoading());

    try {
      final spots = await repository.getSpots(
        event.tab,
        page: 1,
        pageSize: _pageSize,
        locale: locale,
      );

      _cache[event.tab] ??= {};
      _cache[event.tab]![locale] = spots;

      _currentPage[event.tab] ??= {};
      _currentPage[event.tab]![locale] = 1;

      _hasReachedMax[event.tab] ??= {};
      _hasReachedMax[event.tab]![locale] = spots.length < _pageSize;

      emit(HomeLoaded(
        spots: spots,
        currentTab: event.tab,
        hasReachedMax: spots.length < _pageSize,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadMoreSpots(
    LoadMoreSpotsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final locale = event.locale;

    if (_hasReachedMax[event.tab]?[locale] == true) return;
    if (state is HomeLoadingMore) return;

    final currentSpots = _cache[event.tab]?[locale] ?? [];
    final currentPage = _currentPage[event.tab]?[locale] ?? 1;

    emit(HomeLoadingMore(
      spots: currentSpots,
      currentTab: event.tab,
    ));

    try {
      final newSpots = await repository.getSpots(
        event.tab,
        page: currentPage + 1,
        pageSize: _pageSize,
        locale: locale,
      );

      final updatedSpots = [...currentSpots, ...newSpots];

      _cache[event.tab]![locale] = updatedSpots;
      _currentPage[event.tab]![locale] = currentPage + 1;
      _hasReachedMax[event.tab]![locale] = newSpots.length < _pageSize;

      emit(HomeLoaded(
        spots: updatedSpots,
        currentTab: event.tab,
        hasReachedMax: newSpots.length < _pageSize,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshSpots(
    RefreshSpotsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final locale = event.locale;

    try {
      final spots = await repository.refresh(
        event.tab,
        page: 1,
        pageSize: _pageSize,
        locale: locale,
      );

      _cache[event.tab] ??= {};
      _cache[event.tab]![locale] = spots;

      _currentPage[event.tab] ??= {};
      _currentPage[event.tab]![locale] = 1;

      _hasReachedMax[event.tab] ??= {};
      _hasReachedMax[event.tab]![locale] = spots.length < _pageSize;

      emit(HomeLoaded(
        spots: spots,
        currentTab: event.tab,
        hasReachedMax: spots.length < _pageSize,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // ✅ Clear cache VÀ reload tab hiện tại
  Future<void> _onLocaleChanged(
    LocaleChangedEvent event,
    Emitter<HomeState> emit,
  ) async {
    // ✅ Clear toàn bộ cache khi đổi locale
    _cache.clear();
    _currentPage.clear();
    _hasReachedMax.clear();

    // ✅ Reload lại tab hiện tại
    if (state is HomeLoaded) {
      final currentTab = (state as HomeLoaded).currentTab;
      add(LoadSpotsEvent(currentTab, event.locale));
    }
  }
}
