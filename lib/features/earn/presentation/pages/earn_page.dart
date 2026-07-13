import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/services/ad_service.dart';
import '../../../../core/services/connectivity_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/offline_banner.dart';
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
          final isConnected = context.watch<ConnectivityCubit>().state;
          return SafeArea(
            child: Column(
              children: [
                if (!isConnected) const OfflineBanner(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: isConnected
                                ? colors.primaryContainer
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.monetization_on_rounded,
                            size: 56,
                            color: isConnected
                                ? colors.onPrimaryContainer
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Gagne 5 points par vidéo',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isConnected
                              ? 'Regarde une courte vidéo publicitaire '
                                  'et gagne 5 points.\n'
                                  'Tu peux regarder autant de vidéos '
                                  'que tu veux !'
                              : 'Connecte-toi à internet pour regarder '
                                  'des vidéos et gagner des points.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isConnected
                                ? Colors.grey.shade600
                                : Colors.grey.shade500,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isConnected
                                  ? colors.outlineVariant
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isConnected
                                            ? Colors.amber.withValues(alpha: 0.15)
                                            : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.star_rounded,
                                        color: isConnected
                                            ? Colors.amber.shade700
                                            : Colors.grey,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Récompense',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isConnected
                                                ? '5 points par vidéo regardée'
                                                : 'Indisponible hors ligne',
                                            style: TextStyle(
                                              color: isConnected
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade400,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '+5',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isConnected
                                            ? colors.primary
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Regarder une vidéo',
                          icon: Icons.play_circle_fill_rounded,
                          isLoading: _isLoading ||
                              state.status == EarnStatus.submitting,
                          onPressed: _isLoading ? null : _loadAndShowAd,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Les points sont ajoutés immédiatement '
                          'après la fin de la vidéo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
