import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/services/ad_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/earn_bloc.dart';

class EarnPage extends StatefulWidget {
  const EarnPage({super.key});

  @override
  State<EarnPage> createState() => _EarnPageState();
}

class _EarnPageState extends State<EarnPage> {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAndShowAd() async {
    setState(() => _isLoading = true);

    final ad = await AdService.loadRewardedAd();
    if (ad == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune vidéo disponible pour le moment')),
        );
      }
      return;
    }
    if (!mounted) return;

    _rewardedAd = ad;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        setState(() => _isLoading = false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la lecture de la vidéo')),
        );
      },
    );

    final uid = context.read<AuthBloc>().state.user.uid;

    ad.show(onUserEarnedReward: (ad, reward) {
      context.read<EarnBloc>().add(EarnRewardWatched(uid));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gagner des points')),
      body: BlocConsumer<EarnBloc, EarnState>(
        listener: (context, state) {
          if (state.status == EarnStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('+5 points ! Continue comme ça !'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == EarnStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Erreur')),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.monetization_on_rounded,
                    size: 120,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gagne 5 points par vidéo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Regarde une courte vidéo publicitaire et gagne 5 points.\n'
                    'Tu peux regarder autant de vidéos que tu veux !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 40),
                  AppButton(
                    label: 'Regarder une vidéo',
                    icon: Icons.play_circle_fill_rounded,
                    isLoading: _isLoading || state.status == EarnStatus.submitting,
                    onPressed: _isLoading ? null : _loadAndShowAd,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Les points sont ajoutés immédiatement après la fin de la vidéo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
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
