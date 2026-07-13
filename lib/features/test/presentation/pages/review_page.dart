import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/test_app.dart';
import '../bloc/review_bloc.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.test});

  final TestApp test;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _currentStep = 0;
  String? _screenshot1Path;
  String? _screenshot2Path;

  Future<void> _showInterstitialThenGoHome() async {
    final ad = await AdService.loadInterstitialAd();
    if (ad != null && mounted) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (mounted) {
            context.go(
              '/test/${widget.test.id}/confirmation',
              extra: widget.test,
            );
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          if (mounted) {
            context.go(
              '/test/${widget.test.id}/confirmation',
              extra: widget.test,
            );
          }
        },
      );
      ad.show();
    } else {
      if (mounted) {
        context.go('/test/${widget.test.id}/confirmation', extra: widget.test);
      }
    }
  }

  Future<void> _pickScreenshot1() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _screenshot1Path = picked.path);
    }
  }

  Future<void> _pickScreenshot2() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _screenshot2Path = picked.path);
    }
  }

  Future<void> _openPlayStoreReview() async {
    final uri = Uri.parse(widget.test.playStoreUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le Play Store')),
        );
      }
    }
  }

  void _submit() {
    if (_screenshot1Path == null || _screenshot2Path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les 2 captures d\'écran'),
        ),
      );
      return;
    }
    final user = context.read<AuthBloc>().state.user;
    context.read<ReviewBloc>().add(
      ReviewSubmitted(
        userId: user.uid,
        userName: user.name,
        testId: widget.test.id,
        testName: widget.test.title,
        screenshot1Path: _screenshot1Path!,
        screenshot2Path: _screenshot2Path!,
        appName: widget.test.title,
        playStoreUrl: widget.test.playStoreUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Donner mon avis')),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state.status == ReviewStatus.success) {
            _showInterstitialThenGoHome();
          } else if (state.status == ReviewStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Erreur')),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rate_review_rounded,
                      size: 32,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Termine les étapes pour gagner tes points',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _StepIndicator(
                    currentStep: _currentStep,
                    steps: const [
                      "Laisser un avis Google Play",
                      "Capture d'écran 1 — Installation",
                      "Capture d'écran 2 — Avis",
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildStepContent(colors),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Les points seront crédités après vérification '
                            'manuelle de tes captures.',
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Envoyer pour validation',
                    isLoading: state.status == ReviewStatus.submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(ColorScheme colors) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Ouvre le Play Store, note l'application "
              'et laisse un commentaire.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openPlayStoreReview,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ouvrir Google Play'),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Prends une capture d'écran de l'application installée.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            if (_screenshot1Path != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_screenshot1Path!),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickScreenshot1,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _screenshot1Path != null ? 'Modifier' : 'Sélectionner',
                ),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Capture ton avis (note + commentaire) sur Google Play.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            if (_screenshot2Path != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_screenshot2Path!),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickScreenshot2,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _screenshot2Path != null ? 'Modifier' : 'Sélectionner',
                ),
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
