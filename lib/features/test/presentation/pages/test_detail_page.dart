import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_widgets.dart';
import '../bloc/test_detail_bloc.dart';
import '../widgets/step_item.dart';

class TestDetailPage extends StatelessWidget {
  const TestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail')),
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
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: test.iconUrl,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 96,
                              height: 96,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.apps, size: 40),
                            ),
                          ),
                        ),
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
                  onPressed: () =>
                      context.push('/test/${test.id}/progress', extra: test),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
