import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: colors.primaryContainer),
              accountName: Text(
                user.name,
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
              accountEmail: Text(
                user.email,
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: colors.primary,
                child: Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 24,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Accueil'),
              onTap: () => _navigate(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on_rounded),
              title: const Text('Gagner des points'),
              onTap: () => _navigate(context, '/earn'),
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Mon historique'),
              onTap: () => _navigate(context, '/rewards'),
            ),
            if (user.isAdmin)
              ListTile(
                leading: const Icon(Icons.verified_rounded),
                title: const Text('Validation admin'),
                onTap: () => _navigate(context, '/admin/validation'),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('À propos'),
              onTap: () => _navigate(context, '/about'),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Suggestion'),
              onTap: () => _navigate(context, '/feedback'),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text('Se déconnecter',
                  style: TextStyle(color: colors.error)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String path) {
    Navigator.pop(context);
    context.push(path);
  }
}
