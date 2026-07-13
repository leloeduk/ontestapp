import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_status_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../test/data/models/review_model.dart';
import '../../../test/data/repositories/review_repository.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ReviewModel>? _reviews;
  bool _loading = false;
  DateTime? _lastLoad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    _lastLoad = DateTime.now();
    final uid = context.read<AuthBloc>().state.user.uid;
    try {
      final reviews = await context.read<ReviewRepository>().getReviewsByUser(uid);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_reviews != null && !_loading &&
        DateTime.now().difference(_lastLoad ?? DateTime(0)).inSeconds > 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
    if (_loading && _reviews == null) return const LoadingView();

    final reviews = _reviews ?? [];
    if (reviews.isEmpty) {
      return const EmptyView(message: 'Aucun historique');
    }

    final colors = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final review = reviews[i];
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: review.testValidated
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  review.testValidated
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_empty_rounded,
                  color: review.testValidated ? Colors.green : Colors.orange,
                  size: 22,
                ),
              ),
              title: Text(
                review.testName ?? 'Test',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                review.testValidated ? 'Validé (+${review.rewardPoints} pts)' : 'En attente de validation',
                style: TextStyle(
                  fontSize: 12,
                  color: review.testValidated ? Colors.green : Colors.orange,
                ),
              ),
              trailing: review.testValidated
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${review.rewardPoints}',
                        style: TextStyle(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
