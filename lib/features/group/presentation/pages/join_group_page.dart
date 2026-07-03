import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/group_bloc.dart';

class JoinGroupPage extends StatelessWidget {
  const JoinGroupPage({super.key});

  Future<void> _openGroup(BuildContext context) async {
    final uri = Uri.parse(AppConstants.groupUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejoindre le groupe')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.groups_rounded,
                  size: 96, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Rejoins notre groupe',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pour tester les applications, tu dois d\'abord rejoindre '
                'notre groupe Google. C\'est obligatoire pour accéder aux '
                'tests fermés du Play Store.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Ouvrir le groupe',
                icon: Icons.open_in_new,
                onPressed: () => _openGroup(context),
              ),
              const SizedBox(height: 16),
              BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  return OutlinedButton(
                    onPressed: state.status == GroupStatus.submitting
                        ? null
                        : () {
                            final uid =
                                context.read<AuthBloc>().state.user.uid;
                            context
                                .read<GroupBloc>()
                                .add(GroupJoinRequested(uid));
                          },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: state.status == GroupStatus.submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('J\'ai déjà rejoint'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
