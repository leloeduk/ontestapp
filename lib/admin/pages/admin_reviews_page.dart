import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/app_image.dart';
import '../../core/widgets/app_status_widgets.dart';
import '../bloc/admin_bloc.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  bool _validating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminBloc>().add(const AdminReviewsRequested()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soumissions en attente')),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state.status == AdminStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Erreur')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AdminStatus.loading) {
            return const Center(child: LoadingView());
          }

          final reviews = state.reviews;

          if (reviews.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Toutes les soumissions sont traitées',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _ReviewCard(
                review: review,
                validating: _validating,
                onValidate: () async {
                  setState(() => _validating = true);
                  context.read<AdminBloc>().add(
                    AdminValidateReview(
                      reviewId: review.id,
                      userId: review.userId,
                      rewardPoints: review.rewardPoints,
                    ),
                  );
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (mounted) setState(() => _validating = false);
                },
                onDelete: () => _confirmDelete(context, review),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic review) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text(
          'Supprimer cette soumission ? Les captures seront aussi effacées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(
                AdminDeleteReview(
                  reviewId: review.id,
                  screenshot1Url: review.screenshot1Url,
                  screenshot2Url: review.screenshot2Url,
                ),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.validating,
    required this.onValidate,
    required this.onDelete,
  });

  final dynamic review;
  final bool validating;
  final VoidCallback onValidate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_rounded, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.userName ?? 'Utilisateur inconnu',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (review.testName != null) ...[
              const SizedBox(height: 4),
              Text(
                review.testName!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            if (review.playStoreUrl != null && review.playStoreUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Voir sur le Play Store'),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ScreenshotTile(
                    url: review.screenshot1Url,
                    label: 'Capture 1 (Installation)',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScreenshotTile(
                    url: review.screenshot2Url,
                    label: 'Capture 2 (Avis)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: validating ? null : onValidate,
                    icon: validating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(validating ? 'Validation...' : 'Valider'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenshotTile extends StatelessWidget {
  const _ScreenshotTile({
    required this.url,
    required this.label,
  });

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppImage(
            imageUrl: url,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
