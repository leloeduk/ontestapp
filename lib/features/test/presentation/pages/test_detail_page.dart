import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_status_widgets.dart';
import '../../../auth/data/services/user_service.dart';
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
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _startTest(TestApp test) async {
    setState(() => _isAdLoading = true);

    final ad = await AdService.loadRewardedAd();
    if (ad == null) {
      if (mounted) {
        setState(() => _isAdLoading = false);
        context.push('/test/${test.id}/progress', extra: test);
      }
      return;
    }
    if (!mounted) return;

    final completer = Completer<void>();
    _rewardedAd = ad;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        if (!completer.isCompleted) completer.complete();
      },
    );

    final uid = context.read<AuthBloc>().state.user.uid;
    final userService = context.read<UserService>();
    bool rewarded = false;

    ad.show(onUserEarnedReward: (ad, reward) {
      rewarded = true;
      userService.addPointsForReward(uid, points: 5);
    });

    await completer.future;

    if (mounted) {
      setState(() => _isAdLoading = false);
      if (rewarded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+5 points pour avoir regardé la vidéo !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
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
                    context.push('/test/${state.test!.id}/edit',
                        extra: state.test);
                  } else if (value == 'delete') {
                    final confirmed =
                        await _confirmDelete(context);
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
                      title: Text('Supprimer',
                          style: TextStyle(color: Colors.red)),
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
            return ErrorView(
              message: state.errorMessage ?? 'Erreur',
            );
          }

          final test = state.test!;
          final colors = Theme.of(context).colorScheme;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppImage(
                        imageUrl: test.iconUrl,
                        width: 96,
                        height: 96,
                        borderRadius: 20,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          test.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+${test.points} points',
                            style: TextStyle(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Description',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(test.description),
                      if (test.steps.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Étapes à suivre',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        for (int i = 0; i < test.steps.length; i++)
                          StepItem(number: i + 1, text: test.steps[i]),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(
                  label: 'Tester maintenant',
                  icon: Icons.play_arrow_rounded,
                  isLoading: _isAdLoading,
                  onPressed: () => _startTest(test),
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
