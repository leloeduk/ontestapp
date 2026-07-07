import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_status_widgets.dart';
import '../../../test/data/repositories/test_repository.dart';
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
        content: const Text('Les points seront crédités à l\'utilisateur.'),
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

  Future<void> _deleteTest(String testId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce test ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final testRepo = context.read<TestRepository>();
      final validationBloc = context.read<AdminValidationBloc>();
      await testRepo.deleteTest(testId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Test supprimé')));
        validationBloc.add(const AdminValidationRequested());
      }
    }
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
            return const Center(child: Text('Aucune soumission en attente'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: state.reviews.length,
            itemBuilder: (_, i) {
              final review = state.reviews[i];
              final testsCount = state.userTestsCount[review.userId] ?? 0;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
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
                          Column(
                            children: [
                              Text(
                                '$testsCount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'test${testsCount > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
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
                                const Text(
                                  'Capture 1',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      review.screenshot1Url.startsWith('http')
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
                                            child: Text('Aucune capture'),
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  review.screenshot1Url,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Capture 2',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      review.screenshot1Url.startsWith('http')
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
                                            child: Text('Aucune capture'),
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  review.screenshot2Url,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (review.playStoreUrl != null) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _openPlayStore(review.playStoreUrl!),
                          child: Row(
                            children: [
                              Icon(
                                Icons.open_in_new,
                                size: 14,
                                color: colors.primary,
                              ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _deleteTest(review.testId),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Supprimer'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.error,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: AppButton(
                              label: 'Valider(${review.rewardPoints}pts)',
                              isLoading:
                                  state.status ==
                                  AdminValidationStatus.validating,
                              onPressed: () => _validate(review),
                            ),
                          ),
                        ],
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
