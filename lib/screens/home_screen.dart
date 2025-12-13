import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/home/home_bloc.dart';
import 'package:snapgo/blocs/home/home_event.dart';
import 'package:snapgo/blocs/home/home_state.dart';
import 'package:snapgo/widgets/spot_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenView();
  }
}

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  _HomeScreenViewState createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ Map ScrollController cho từng tab
  final Map<String, ScrollController> _scrollControllers = {};

  final List<String> _tabs = ['trending', 'newest'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ Tạo ScrollController riêng cho mỗi tab
    for (var tab in _tabs) {
      _scrollControllers[tab] = ScrollController()
        ..addListener(() => _onScroll(tab));
    }

    // Listener cho tab change
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final tab = _tabs[_tabController.index];
        context.read<HomeBloc>().add(LoadSpotsEvent(tab));
      }
    });

    // Load data lần đầu
    context.read<HomeBloc>().add(LoadSpotsEvent(_tabs[0]));
  }

  // ✅ Nhận tab parameter để biết scroll của tab nào
  void _onScroll(String tab) {
    final controller = _scrollControllers[tab]!;

    if (!controller.hasClients) return;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;

    // Chỉ trigger khi đang ở tab đúng
    if (currentScroll >= (maxScroll * 0.9) &&
        _tabs[_tabController.index] == tab) {
      context.read<HomeBloc>().add(LoadMoreSpotsEvent(tab));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // ✅ Dispose tất cả controllers
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> tabLabels = [
      l10n.trending,
      l10n.bySeason,
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          l10n.exploreSaigon,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context)
                  .elevatedButtonTheme
                  .style
                  ?.backgroundColor
                  ?.resolve({}),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue[700],
          indicatorWeight: 2,
          tabs: tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_outlined,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Oops!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<HomeBloc>()
                            .add(LoadSpotsEvent(_tabs[_tabController.index]));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is HomeLoaded || state is HomeLoadingMore) {
            final spots = state is HomeLoaded
                ? state.spots
                : (state as HomeLoadingMore).spots;

            final currentTab = state is HomeLoaded
                ? state.currentTab
                : (state as HomeLoadingMore).currentTab;

            final hasReachedMax =
                state is HomeLoaded ? state.hasReachedMax : false;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(RefreshSpotsEvent(currentTab));
              },
              child: ListView.builder(
                // key: ValueKey(currentTab),
                // ✅ Dùng ScrollController của tab hiện tại
                controller: _scrollControllers[currentTab],
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: spots.length + (hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= spots.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return SpotCard(
                    key: ValueKey(spots[index].id),
                    spot: spots[index],
                  );
                },
              ),
            );
          }

          return Center(child: Text(l10n.pullToRefresh));
        },
      ),
    );
  }
}
