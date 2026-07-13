import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('OntestApp')),
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.phone_android_outlined),
            selectedIcon: Icon(Icons.phone_android_rounded),
            label: 'Mes tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
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

class _TestsTab extends StatelessWidget {
  const _TestsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading) {
          return const LoadingView();
        }
        if (state.status == HomeStatus.error) {
          return const ErrorView(message: 'Impossible de charger les tests');
        }

        return CustomScrollView(
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
                  'Applications à tester',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            if (state.tests.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(message: 'Aucune application pour le moment'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList.separated(
                  itemCount: state.tests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
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
                      'Gagne des points',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Regarde une vidéo et gagne 5 points',
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
