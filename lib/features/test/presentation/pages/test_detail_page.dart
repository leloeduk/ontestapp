import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/services/ad_service.dart';
import '../../../../core/services/connectivity_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_status_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/test_app.dart';
import '../bloc/edit_test_bloc.dart';
import '../bloc/test_detail_bloc.dart';
import '../widgets/step_item.dart';

class TestDetailPage extends StatefulWidget {
  const TestDetailPage({super.key});

  @override
  State<TestDetailPage> createState() => _TestDetailPageState();
}

class _TestDetailPageState extends State<TestDetailPage> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  bool get _isOffline =>
      context.read<ConnectivityCubit>().state == false;

  Future<void> _startTest(TestApp test) async {
    setState(() => _isAdLoading = true);

    if (!_isOffline) {
      final ad = await AdService.loadInterstitialAd();
      if (ad != null && mounted) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (_) {
            ad.dispose();
            _interstitialAd = null;
            if (mounted) {
              setState(() => _isAdLoading = false);
              context.push('/test/${test.id}/progress', extra: test);
            }
          },
          onAdFailedToShowFullScreenContent: (_, __) {
            ad.dispose();
            _interstitialAd = null;
            if (mounted) {
              setState(() => _isAdLoading = false);
              context.push('/test/${test.id}/progress', extra: test);
            }
          },
        );
        ad.show();
        _interstitialAd = ad;
        return;
      }
    }

    if (mounted) {
      setState(() => _isAdLoading = false);
      context.push('/test/${test.id}/progress', extra: test);
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Veux-tu vraiment supprimer cette application ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ).then((v) => v ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<AuthBloc>().state.user.uid;
    return BlocListener<EditTestBloc, EditTestState>(
      listener: (context, state) {
        if (state.status == EditTestStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application supprimée')),
          );
          context.pop();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détail'),
          actions: [
            BlocBuilder<TestDetailBloc, TestDetailState>(
              builder: (context, state) {
                if (state.test == null || state.test!.userId != currentUid) {
                  return const SizedBox.shrink();
                }
                return PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push(
                        '/test/${state.test!.id}/edit',
                        extra: state.test,
                      );
                    } else if (value == 'delete') {
                      final confirmed = await _confirmDelete(context);
                      if (confirmed && context.mounted) {
                        context.read<EditTestBloc>().add(
                          DeleteTestRequested(state.test!.id),
                        );
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Modifier'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TestDetailBloc, TestDetailState>(
          builder: (context, state) {
            if (state.status == TestDetailStatus.loading) {
              return const LoadingView();
            }
            if (state.status == TestDetailStatus.error || state.test == null) {
              return ErrorView(message: state.errorMessage ?? 'Erreur');
            }

            final test = state.test!;
            final colors = Theme.of(context).colorScheme;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppImage(
                              imageUrl: test.iconUrl,
                              width: 88,
                              height: 88,
                              borderRadius: 20,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    test.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      test.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primaryContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.emoji_events_rounded,
                                          size: 16,
                                          color: colors.onPrimaryContainer,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${test.points} points',
                                          style: TextStyle(
                                            color: colors.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _SectionHeader(title: 'Description'),
                        const SizedBox(height: 8),
                        Text(
                          test.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        if (test.steps.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _SectionHeader(title: 'Étapes à suivre'),
                          const SizedBox(height: 12),
                          for (int i = 0; i < test.steps.length; i++)
                            StepItem(number: i + 1, text: test.steps[i]),
                        ],
                        const SizedBox(height: 28),
                        _SectionHeader(title: 'Ce que vous devez faire'),
                        const SizedBox(height: 12),
                        _ChecklistItem(
                          icon: Icons.play_circle_rounded,
                          text: 'Suivre une vidéo pour gagner 5 points',
                        ),
                        _ChecklistItem(
                          icon: Icons.download_rounded,
                          text: "Télécharger et installer l'application",
                        ),
                        _ChecklistItem(
                          icon: Icons.rate_review_rounded,
                          text: "Donner mon avis sur l'application",
                        ),
                        _ChecklistItem(
                          icon: Icons.screenshot_rounded,
                          text: "Une capture d'écran de l'app installée",
                        ),
                        _ChecklistItem(
                          icon: Icons.screenshot_rounded,
                          text: "Une capture d'écran de mon avis",
                        ),
                        _ChecklistItem(
                          icon: Icons.verified_rounded,
                          text: 'Les deux captures validées = 10 points',
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: AppButton(
                    label: 'Tester maintenant',
                    icon: Icons.play_arrow_rounded,
                    isLoading: _isAdLoading,
                    onPressed: _isAdLoading ? null : () => _startTest(test),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
