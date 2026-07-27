import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../constants/app_constants.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_cubit.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final colors = Theme.of(context).colorScheme;
    final tr = AppLocalizations.of(context);

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user.email,
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _DrawerTile(
            icon: Icons.home_rounded,
            title: tr.home,
            onTap: () => _navigate(context, '/home'),
          ),
          _DrawerTile(
            icon: Icons.monetization_on_rounded,
            title: tr.earnPoints,
            onTap: () => _navigate(context, '/earn'),
          ),
          _DrawerTile(
            icon: Icons.history_rounded,
            title: tr.myHistory,
            onTap: () => _navigate(context, '/rewards'),
          ),
          if (user.isAdmin)
            _DrawerTile(
              icon: Icons.verified_rounded,
              title: tr.adminValidation,
              onTap: () => _navigate(context, '/admin/validation'),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _DrawerTile(
            icon: Icons.info_outline_rounded,
            title: tr.about,
            onTap: () => _navigate(context, '/about'),
          ),
          _DrawerTile(
            icon: Icons.feedback_outlined,
            title: tr.feedback,
            onTap: () => _navigate(context, '/feedback'),
          ),
          _DrawerTile(
            icon: Icons.chat_rounded,
            title: tr.joinWhatsApp,
            onTap: () => _openWhatsApp(context),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _LanguageTile(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          _DrawerTile(
            icon: Icons.logout,
            title: tr.signOut,
            iconColor: colors.error,
            textColor: colors.error,
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String path) {
    Navigator.pop(context);
    context.push(path);
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    Navigator.pop(context);
    final uri = Uri.parse(AppConstants.whatsappGroupUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final isFrench = locale.languageCode == 'fr';

    return ListTile(
      leading: const Icon(Icons.language),
      trailing: SegmentedButton<String>(
        segments: [
          ButtonSegment(value: 'fr', label: Text(tr.french)),
          ButtonSegment(value: 'en', label: Text(tr.english)),
        ],
        selected: {isFrench ? 'fr' : 'en'},
        onSelectionChanged: (selected) {
          final code = selected.first;
          context.read<LocaleCubit>().setLocale(Locale(code));
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
