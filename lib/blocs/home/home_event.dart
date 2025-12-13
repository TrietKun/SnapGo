abstract class HomeEvent {}

class LoadSpotsEvent extends HomeEvent {
  final String tab;
  LoadSpotsEvent(this.tab);
}

class LoadMoreSpotsEvent extends HomeEvent {
  final String tab;
  LoadMoreSpotsEvent(this.tab);
}

class RefreshSpotsEvent extends HomeEvent {
  final String tab;
  RefreshSpotsEvent(this.tab);
}