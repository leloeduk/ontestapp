import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ontestapp/core/widgets/stepped.dart';
import 'package:url_launcher/url_launcher.dart';

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

  List<Step> _buildSteps(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return [
      Step(
        title: const Text('Étape 1'),
        subtitle: const Text('Ouvrir le Play Store'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Ouvre l'application sur le Play Store pour accéder "
              'à la page officielle et sécurisée.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _openStore(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir le Play Store'),
            ),
          ],
        ),
        isActive: true,
      ),
      Step(
        title: const Text('Étape 2'),
        subtitle: const Text('Installer et tester'),
        content: const Text(
          "Installe l'application depuis le Play Store et utilise-la "
          'quelques instants pour vérifier son bon fonctionnement.',
        ),
        isActive: true,
      ),
      Step(
        title: const Text('Étape 3'),
        subtitle: const Text('Donner ton avis'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Reviens ici et donne ton avis sur l'application. "
              'Ton retour aide à améliorer l’application.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  context.push('/test/${test.id}/review', extra: test),
              icon: Icon(Icons.rate_review, color: colors.onPrimary),
              label: const Text("J'ai testé — Donner mon avis"),
            ),
          ],
        ),
        isActive: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(test.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.download_for_offline_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Test en cours',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ReviewStepper(steps: _buildSteps(context)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
