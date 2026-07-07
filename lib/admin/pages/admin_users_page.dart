import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/app_status_widgets.dart';
import '../bloc/admin_bloc.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminBloc>().add(const AdminUsersRequested()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state.status == AdminStatus.loading) {
            return const Center(child: LoadingView());
          }
          if (state.status == AdminStatus.error) {
            return Center(child: ErrorView(message: state.errorMessage ?? ''));
          }

          final users = state.users;

          if (users.isEmpty) {
            return const Center(child: Text('Aucun utilisateur'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      ((user['name'] as String?)?.isNotEmpty == true
                              ? user['name']![0]
                              : '?')
                          .toUpperCase(),
                    ),
                  ),
                  title: Text(
                    user['name'] as String? ?? 'Inconnu',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(user['email'] as String? ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Chip(
                        label: '${user['points']} pts',
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        label: '${user['testsDone']} tests',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      if (user['isAdmin'] == true)
                        const _Chip(label: 'Admin', color: Colors.green),
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
