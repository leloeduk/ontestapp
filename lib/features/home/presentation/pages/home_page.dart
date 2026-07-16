import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/connectivity_cubit.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_status_widgets.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../bloc/home_bloc.dart';
import '../widgets/points_header.dart';
import '../widgets/test_card.dart';
import 'history_page.dart';
import 'my_tests_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  String _lastLocation = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastLocation = _currentLocation();
    GoRouter.of(context).routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    try {
      GoRouter.of(context).routerDelegate.removeListener(_onRouteChanged);
    } catch (_) {}
    super.dispose();
  }

  String _currentLocation() {
    return GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.toString();
  }

  void _onRouteChanged() {
    try {
      final loc = _currentLocation();
      if (loc != _lastLocation) {
        _lastLocation = loc;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.appTitle)),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const _ConnectivityBanner(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                _TestsTab(),
                MyTestsPage(),
                HistoryPage(),
                ProfilePage(),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: tr.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.phone_android_outlined),
            selectedIcon: const Icon(Icons.phone_android_rounded),
            label: tr.myTests,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history_rounded),
            label: tr.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person_rounded),
            label: tr.profile,
          ),
        ],
      ),
    );
  }
}

class _ConnectivityBanner extends StatelessWidget {
  const _ConnectivityBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isConnected) {
        if (!isConnected) {
          return const OfflineBanner();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TestsTab extends StatefulWidget {
  const _TestsTab();

  @override
  State<_TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends State<_TestsTab> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeTestsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading) {
          return const LoadingView();
        }
        if (state.status == HomeStatus.error) {
          return ErrorView(
            message: tr.cantLoadTests,
            onRetry: () =>
                context.read<HomeBloc>().add(const HomeTestsRequested()),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeTestsRequested());
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      const _PointsHeaderWidget(),
                      const SizedBox(height: 16),
                      const _EarnCard(),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    tr.appsToTest,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              if (state.tests.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(message: tr.noApps),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList.separated(
                    itemCount: state.tests.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == state.tests.length) {
                        return state.status == HomeStatus.loadingMore
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Center(
                                child: TextButton.icon(
                                  onPressed: () => context
                                      .read<HomeBloc>()
                                      .add(const HomeTestsLoadMore()),
                                  icon: const Icon(Icons.expand_more),
                                  label: Text(tr.seeMore),
                                ),
                              );
                      }
                      final test = state.tests[i];
                      return TestCard(
                        test: test,
                        onTap: () =>
                            context.push('/test/${test.id}', extra: test),
                      );
                    },
                  ),
                ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 16),
                sliver: SliverToBoxAdapter(child: SizedBox(height: 8)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PointsHeaderWidget extends StatelessWidget {
  const _PointsHeaderWidget();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    return PointsHeader(user: user);
  }
}

class _EarnCard extends StatelessWidget {
  const _EarnCard();

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.tertiaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/earn'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.onTertiaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.monetization_on_rounded,
                  color: colors.onTertiaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.earnPointsCard,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr.watchAndEarn,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onTertiaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colors.onTertiaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
