import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/test_app.dart';

class TestInProgressPage extends StatefulWidget {
  const TestInProgressPage({super.key, required this.test});

  final TestApp test;

  @override
  State<TestInProgressPage> createState() => _TestInProgressPageState();
}

class _TestInProgressPageState extends State<TestInProgressPage> {
  int _currentStep = 0;

  Future<void> _openStore() async {
    final uri = Uri.parse(widget.test.playStoreUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le Play Store')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.test.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.download_for_offline_outlined,
                  size: 96,
                  color: colors.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Test en cours',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                ..._buildIndicator(colors),
                const SizedBox(height: 20),
                _buildStepContent(context, colors),
                const SizedBox(height: 20),
                Wrap(
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Précédent'),
                      ),
                    const SizedBox(height: 20),
                    if (_currentStep > 0) const SizedBox(width: 20),
                    if (_currentStep < 2)
                      FilledButton(
                        onPressed: () => setState(() => _currentStep++),
                        child: const Text('Suivant'),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIndicator(ColorScheme colors) {
    const titles = [
      'Ouvrir le Play Store',
      'Installer et tester',
      "Donner ton avis",
    ];
    return titles.asMap().entries.map((entry) {
      final i = entry.key;
      final title = entry.value;
      final isActive = i == _currentStep;
      final isCompleted = i < _currentStep;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? colors.primary
                    : isActive
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive || isCompleted
                    ? colors.onSurface
                    : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildStepContent(BuildContext context, ColorScheme colors) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Ouvre l'application sur le Play Store pour accéder "
              'à la page officielle et sécurisée.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _openStore,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir le Play Store'),
            ),
          ],
        );
      case 1:
        return const Text(
          "Installe l'application depuis le Play Store et utilise-la "
          'quelques instants pour vérifier son bon fonctionnement.',
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Reviens ici et donne ton avis sur l'application. "
              'Ton retour aide à améliorer l’application.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push(
                '/test/${widget.test.id}/review',
                extra: widget.test,
              ),
              icon: Icon(Icons.rate_review, color: colors.onPrimary),
              label: const Text("J'ai testé — Donner mon avis"),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
