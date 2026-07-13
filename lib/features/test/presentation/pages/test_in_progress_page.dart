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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.download_for_offline_outlined,
                    size: 52,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Test en cours',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              _StepIndicator(
                currentStep: _currentStep,
                steps: const [
                  'Ouvrir le Play Store',
                  'Installer et tester',
                  "Donner ton avis",
                ],
              ),
              const SizedBox(height: 32),
              _buildStepContent(colors),
              const Spacer(flex: 2),
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Précédent'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  if (_currentStep < 2)
                    Expanded(
                      child: FilledButton(
                        onPressed: () => setState(() => _currentStep++),
                        child: const Text('Suivant'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(ColorScheme colors) {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            Text(
              "Ouvre l'application sur le Play Store pour accéder "
              'à la page officielle et sécurisée.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openStore,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ouvrir le Play Store'),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            Text(
              "Installe l'application depuis le Play Store et utilise-la "
              'quelques instants pour vérifier son bon fonctionnement.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.tertiaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    color: colors.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Teste toutes les fonctionnalités '
                      'pour donner un avis complet.',
                      style: TextStyle(
                        color: colors.onTertiaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Text(
              "Reviens ici et donne ton avis sur l'application. "
              'Ton retour aide à améliorer l’application.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(
                  '/test/${widget.test.id}/review',
                  extra: widget.test,
                ),
                icon: Icon(Icons.rate_review, color: colors.onPrimary),
                label: const Text("J'ai testé — Donner mon avis"),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final title = entry.value;
        final isActive = i == currentStep;
        final isCompleted = i < currentStep;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? colors.primary
                      : isActive
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  border: isActive && !isCompleted
                      ? Border.all(color: colors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, size: 18, color: colors.onPrimary)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? colors.onPrimaryContainer
                                : colors.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 15,
                  color: isActive || isCompleted
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
