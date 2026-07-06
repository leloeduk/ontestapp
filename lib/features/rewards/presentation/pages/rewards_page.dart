import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_status_widgets.dart';
import '../bloc/rewards_bloc.dart';

class RewardsPage extends StatefulWidget {
  // passe l'ID de l'utilisateur actuel en paramètre
  final String userId;

  const RewardsPage({super.key, required this.userId});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  initState() {
    super.initState();
    context.read<RewardsBloc>().add(
      RewardsRequested(widget.userId),
    ); // Utilise l'ID de l'utilisateur passé en paramètre
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon historique')),
      body: BlocBuilder<RewardsBloc, RewardsState>(
        builder: (context, state) {
          if (state.status == RewardsStatus.idle ||
              state.status == RewardsStatus.loading) {
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
                      '${reviews.length} test${reviews.length > 1 ? 's' : ''} effectué${reviews.length > 1 ? 's' : ''}',
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              if (reviews.isEmpty)
                const Expanded(
                  child: Center(child: Text('Aucun test pour le moment')),
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
                                    if (review.testName != null) ...[
                                      Text(
                                        review.testName!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    Row(
                                      children: [
                                        if (review.testValidated)
                                          Icon(
                                            Icons.check_circle,
                                            size: 18,
                                            color: Colors.green,
                                          )
                                        else
                                          Icon(
                                            Icons.hourglass_empty,
                                            size: 18,
                                            color: Colors.orange,
                                          ),
                                        const SizedBox(width: 6),
                                        Text(
                                          review.testValidated
                                              ? 'Validé'
                                              : 'En attente',
                                          style: TextStyle(
                                            color: review.testValidated
                                                ? Colors.green
                                                : Colors.orange,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (review.testValidated) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
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
