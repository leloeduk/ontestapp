import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_status_widgets.dart';
import '../bloc/rewards_bloc.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon historique')),
      body: BlocBuilder<RewardsBloc, RewardsState>(
        builder: (context, state) {
          if (state.status == RewardsStatus.loading) {
            return const LoadingView();
          }
          if (state.status == RewardsStatus.error) {
            return ErrorView(message: state.errorMessage ?? 'Erreur');
          }

          final reviews = state.reviews;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: colors.primaryContainer,
                child: Column(
                  children: [
                    Text(
                      'Total gagné',
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+${state.totalPoints} pts',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reviews.length} avis publié${reviews.length > 1 ? 's' : ''}',
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              if (reviews.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('Aucun avis pour le moment'),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final review = reviews[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: List.generate(
                                        5,
                                        (j) => Icon(
                                          j < review.rating.round()
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 18,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    if (review.comment.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        review.comment,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '+${review.rewardPoints}',
                                  style: TextStyle(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
