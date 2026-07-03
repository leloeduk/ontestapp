import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/test_app.dart';

class TestInProgressPage extends StatelessWidget {
  const TestInProgressPage({super.key, required this.test});

  final TestApp test;

  Future<void> _openStore(BuildContext context) async {
    final uri = Uri.parse(test.playStoreUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le Play Store')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(test.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.download_for_offline_outlined,
                  size: 96, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Test en cours',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Ouvre l\'application sur le Play Store\n'
                '2. Installe-la et utilise-la quelques instants\n'
                '3. Reviens ici pour donner ton avis et gagner tes points',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Ouvrir sur le Play Store',
                icon: Icons.open_in_new,
                onPressed: () => _openStore(context),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () =>
                    context.push('/test/${test.id}/review', extra: test),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('J\'ai testé — Donner mon avis'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
