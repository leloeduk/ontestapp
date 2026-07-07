import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShellPage extends StatelessWidget {
  const AdminShellPage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final loc = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex(loc),
              onDestinationSelected: (i) => _goTo(context, i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Retour à l\'accueil',
                  onPressed: () => context.go('/home'),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.rate_review_outlined),
                  selectedIcon: Icon(Icons.rate_review_rounded),
                  label: Text('Soumissions'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people_rounded),
                  label: Text('Utilisateurs'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  int _selectedIndex(String loc) {
    if (loc.startsWith('/admin/reviews')) return 1;
    if (loc.startsWith('/admin/users')) return 2;
    return 0;
  }

  void _goTo(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/admin');
      case 1:
        context.go('/admin/reviews');
      case 2:
        context.go('/admin/users');
    }
  }
}
