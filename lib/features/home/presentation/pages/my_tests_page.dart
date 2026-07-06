import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_status_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../test/data/repositories/test_repository.dart';
import '../../../test/domain/entities/test_app.dart';

class MyTestsPage extends StatefulWidget {
  const MyTestsPage({super.key});

  @override
  State<MyTestsPage> createState() => _MyTestsPageState();
}

class _MyTestsPageState extends State<MyTestsPage> {
  List<TestApp>? _tests;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    final uid = context.read<AuthBloc>().state.user.uid;
    try {
      final all = await context.read<TestRepository>().getTests();
      final mine = all.where((t) => t.userId == uid).toList();
      if (mounted) {
        setState(() {
          _tests = mine;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: LoadingView());

    final tests = _tests ?? [];
    if (tests.isEmpty) {
      return const Center(child: EmptyView(message: 'Aucun test soumis'));
    }

    return RefreshIndicator(
      onRefresh: _loadTests,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final test = tests[i];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                test.iconUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.apps, size: 48),
              ),
            ),
            title: Text(test.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${test.points} pts'),
          );
        },
      ),
    );
  }
}
