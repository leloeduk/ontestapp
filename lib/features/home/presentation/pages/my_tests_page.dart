import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_status_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../test/data/repositories/review_repository.dart';
import '../../../test/data/repositories/test_repository.dart';
import '../../../test/domain/entities/test_app.dart';

class MyTestsPage extends StatefulWidget {
  const MyTestsPage({super.key});

  @override
  State<MyTestsPage> createState() => _MyTestsPageState();
}

class _MyTestsPageState extends State<MyTestsPage> {
  List<TestApp>? _tests;
  bool _loading = false;
  int _reviewsCount = 0;
  DateTime? _lastLoad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_tests != null &&
        !_loading &&
        DateTime.now().difference(_lastLoad ?? DateTime(0)).inSeconds > 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
    return _build(context);
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    _lastLoad = DateTime.now();
    final uid = context.read<AuthBloc>().state.user.uid;
    final testRepo = context.read<TestRepository>();
    final reviewRepo = context.read<ReviewRepository>();
    try {
      final all = await testRepo.getTests();
      final mine = all.where((t) => t.userId == uid).toList();
      final reviews = await reviewRepo.getReviewsByUser(uid);
      if (mounted) {
        setState(() {
          _tests = mine;
          _reviewsCount = reviews.length;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteTest(TestApp test) async {
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
      await testRepo.deleteTest(test.id);
      if (mounted) _load();
    }
  }

  Widget _build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_loading && _tests == null) {
      return const Center(child: LoadingView());
    }

    final tests = _tests ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.phone_android_rounded,
                  label: 'Tests soumis',
                  value: '${tests.length}',
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.rate_review_rounded,
                  label: 'Avis donnés',
                  value: '$_reviewsCount',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _AddTestButton(userTestCount: tests.length),
          const SizedBox(height: 16),
          if (tests.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: EmptyView(message: 'Aucun test soumis'),
            )
          else
            ...tests.map(
              (test) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: AppImage(
                    imageUrl: test.iconUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    borderRadius: 8,
                  ),
                  title: Text(
                    test.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${test.points} pts',
                    style: TextStyle(color: colors.primary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: colors.primary,
                          size: 20,
                        ),
                        onPressed: () =>
                            context.push('/test/${test.id}/edit', extra: test),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colors.error,
                          size: 20,
                        ),
                        onPressed: () => _deleteTest(test),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTestButton extends StatelessWidget {
  const _AddTestButton({required this.userTestCount});

  final int userTestCount;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;

    final canAdd = user.points >= 50 &&
        (user.plan != 'free' || userTestCount < 2);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          if (user.points < 50) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('50 points requis pour ajouter un test'),
              ),
            );
          } else if (user.plan == 'free' && userTestCount >= 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Limite du plan gratuit atteinte (2 tests max)'),
              ),
            );
          } else {
            context.push('/add-test');
          }
        },
        icon: Icon(canAdd ? Icons.add : Icons.lock_outline),
        label: const Text('Ajouter un test'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
