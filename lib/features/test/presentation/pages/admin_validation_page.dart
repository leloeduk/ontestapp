import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_status_widgets.dart';
import '../../data/models/review_model.dart';
import '../bloc/admin_validation_bloc.dart';

class AdminValidationPage extends StatefulWidget {
  const AdminValidationPage({super.key});

  @override
  State<AdminValidationPage> createState() => _AdminValidationPageState();
}

class _AdminValidationPageState extends State<AdminValidationPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminValidationBloc>().add(const AdminValidationRequested());
  }

  Future<void> _openPlayStore(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
        );
      }
    }
  }

  void _validate(ReviewModel review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Valider cette soumission ?'),
        content: const Text(
          'Les points seront crédités à l\'utilisateur.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          AppButton(
            label: 'Valider',
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminValidationBloc>().add(
                    AdminValidateReview(
                      reviewId: review.id,
                      userId: review.userId,
                      rewardPoints: review.rewardPoints,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Validation admin')),
      body: BlocBuilder<AdminValidationBloc, AdminValidationState>(
        builder: (context, state) {
          if (state.status == AdminValidationStatus.loading ||
              state.status == AdminValidationStatus.idle) {
            return const LoadingView();
          }
          if (state.status == AdminValidationStatus.error) {
            return ErrorView(message: state.errorMessage ?? 'Erreur');
          }
          if (state.reviews.isEmpty) {
            return const Center(
              child: Text('Aucune soumission en attente'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.reviews.length,
            itemBuilder: (_, i) {
              final review = state.reviews[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: colors.primaryContainer,
                            child: Text(
                              (review.userName ?? '?')[0].toUpperCase(),
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.userName ?? 'Utilisateur',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (review.testName != null)
                                  Text(
                                    review.testName!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Capture 1',
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: review.screenshot1Url.startsWith('http')
                                      ? AppImage(
                                          imageUrl: review.screenshot1Url,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          borderRadius: 8,
                                        )
                                      : Container(
                                          height: 150,
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                              child: Text('Aucune capture')),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Capture 2',
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: review.screenshot1Url.startsWith('http')
                                      ? AppImage(
                                          imageUrl: review.screenshot2Url,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          borderRadius: 8,
                                        )
                                      : Container(
                                          height: 150,
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                              child: Text('Aucune capture')),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (review.playStoreUrl != null) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () =>
                              _openPlayStore(review.playStoreUrl!),
                          child: Row(
                            children: [
                              Icon(Icons.open_in_new,
                                  size: 14, color: colors.primary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  review.playStoreUrl!,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: 'Valider (+${review.rewardPoints} pts)',
                          isLoading: state.status ==
                              AdminValidationStatus.validating,
                          onPressed: () => _validate(review),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
