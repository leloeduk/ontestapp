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
  String? _screenshot1Path;
  String? _screenshot2Path;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showInterstitialThenGoHome() async {
    final ad = await AdService.loadInterstitialAd();
    if (ad != null && mounted) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (mounted) context.go('/test/${widget.test.id}/confirmation');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          if (mounted) context.go('/test/${widget.test.id}/confirmation');
        },
      );
      ad.show();
    } else {
      if (mounted) context.go('/test/${widget.test.id}/confirmation');
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
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Termine les étapes pour gagner tes points',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 32),

                  _StepCard(
                    number: 1,
                    title: 'Laisse un avis sur Google Play',
                    subtitle: 'Ouvre le Play Store, note et commente',
                    icon: Icons.rate_review_outlined,
                    action: _StepAction(
                      label: 'Ouvrir Google Play',
                      onTap: _openPlayStoreReview,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _StepCard(
                    number: 2,
                    title: 'Capture d\'écran 1 — Installation',
                    subtitle: 'Prends une capture de l\'app installée',
                    icon: Icons.phone_android_outlined,
                    imagePath: _screenshot1Path,
                    action: _StepAction(
                      label: _screenshot1Path != null
                          ? 'Modifier'
                          : 'Sélectionner',
                      onTap: _pickScreenshot1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _StepCard(
                    number: 3,
                    title: 'Capture d\'écran 2 — Avis Google Play',
                    subtitle: 'Capture ton avis (note + commentaire)',
                    icon: Icons.screenshot_outlined,
                    imagePath: _screenshot2Path,
                    action: _StepAction(
                      label: _screenshot2Path != null
                          ? 'Modifier'
                          : 'Sélectionner',
                      onTap: _pickScreenshot2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Les points seront crédités après vérification manuelle de tes captures.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
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
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imagePath,
    required this.action,
  });

  final int number;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? imagePath;
  final _StepAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, size: 24, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      Text(subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            if (imagePath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: action.onTap,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(action.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepAction {
  const _StepAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
}
