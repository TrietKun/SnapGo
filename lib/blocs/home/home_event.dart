abstract class HomeEvent {}

class LoadSpotsEvent extends HomeEvent {
  final String tab;
  final String locale; // ✅ Thêm locale
  
  LoadSpotsEvent(this.tab, this.locale);
}

class LoadMoreSpotsEvent extends HomeEvent {
  final String tab;
  final String locale; // ✅ Thêm locale
  
  LoadMoreSpotsEvent(this.tab, this.locale);
}

class RefreshSpotsEvent extends HomeEvent {
  final String tab;
  final String locale; // ✅ Thêm locale
  
  RefreshSpotsEvent(this.tab, this.locale);
}

class LocaleChangedEvent extends HomeEvent {
  final String locale;
  
  LocaleChangedEvent(this.locale);
}