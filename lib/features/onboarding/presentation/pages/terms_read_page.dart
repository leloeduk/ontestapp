import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class TermsReadPage extends StatelessWidget {
  const TermsReadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr.termsOfUse)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.welcomeOnTestApp,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                tr.agreeTerms,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              _Section(
                icon: Icons.group_rounded,
                color: colors,
                title: tr.testerGroup,
                description: tr.testerGroupDesc,
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.smartphone_rounded,
                color: colors,
                title: tr.appTesting,
                description: tr.appTestingDesc,
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.privacy_tip_rounded,
                color: colors,
                title: tr.privacy,
                description: tr.privacyDesc,
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.star_rounded,
                color: colors,
                title: tr.pointsAndRewards,
                description: tr.pointsAndRewardsDesc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final ColorScheme color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color.onPrimaryContainer, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
