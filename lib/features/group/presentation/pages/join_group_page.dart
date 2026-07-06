import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/group_bloc.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  int _step = 0;
  bool _isDeveloper = false;
  bool _playStoreConfirmed = false;

  Future<void> _openGroupLink() async {
    final uri = Uri.parse('https://groups.google.com/g/ontestapp');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Rejoindre le groupe')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepDot(
                    number: 1,
                    label: 'Développeur',
                    active: _step >= 0,
                    done: _step > 0,
                  ),
                  const SizedBox(width: 40, child: Divider(thickness: 2)),
                  _StepDot(
                    number: 2,
                    label: 'Google Group',
                    active: _step >= 1,
                    done: _step > 1,
                  ),
                  if (_isDeveloper) ...[
                    const SizedBox(width: 40, child: Divider(thickness: 2)),
                    _StepDot(
                      number: 3,
                      label: 'Play Console',
                      active: _step >= 2,
                      done: _step > 2,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _step == 0
                    ? _buildStep0(colors)
                    : _step == 1
                        ? _buildStep1(context, colors)
                        : _buildStep2(context, colors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep0(ColorScheme colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/joindgroup.png',
              width: double.infinity,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Es-tu développeur ?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Les développeurs doivent configurer\n'
            'leur piste de test Google Play.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isDeveloper = false;
                      _step = 1;
                    });
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Non'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _isDeveloper = true;
                      _step = 1;
                    });
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Oui'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext context, ColorScheme colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/joindgroup.png',
              width: double.infinity,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rejoins le groupe des testeurs',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tu dois rejoindre le Google Group pour\n'
            'pouvoir tester et faire tester tes applications.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Rejoindre le groupe',
            icon: Icons.open_in_new,
            onPressed: _openGroupLink,
          ),
          const SizedBox(height: 16),
          if (!_isDeveloper)
            _buildValidateButton()
          else
            OutlinedButton.icon(
              onPressed: () => setState(() => _step = 2),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Suivant'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, ColorScheme colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/addgroup.png',
              width: double.infinity,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Configure Google Play Console',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Avant de valider, configure ta piste de test '
            'dans Google Play Console :',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Étapes :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                _StepText('1. Va dans Google Play Console > Pistes de test'),
                _StepText('2. Crée une piste Closed Testing'),
                _StepText(
                  '3. Ajoute ontestapp@googlegroups.com comme testeurs',
                ),
                _StepText('4. Publie la piste'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            value: _playStoreConfirmed,
            onChanged: (v) => setState(() => _playStoreConfirmed = v ?? false),
            title: const Text(
              'J\'ai configuré la piste de test\n'
              'avec le groupe dans Play Console',
              style: TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          _buildValidateButton(),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() => _step = 1),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildValidateButton() {
    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state.status == GroupStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Une erreur est survenue',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSuccessful = state.status == GroupStatus.success;
        final needsPlayStore = _isDeveloper && !_playStoreConfirmed;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: isSuccessful ? 'Terminé !' : 'Valider',
              isLoading: state.status == GroupStatus.submitting,
              onPressed:
                  (needsPlayStore || state.status == GroupStatus.submitting)
                  ? null
                  : () {
                      final user = context.read<AuthBloc>().state.user;
                      context.read<GroupBloc>().add(
                        GroupJoinRequested(
                          uid: user.uid,
                          testerEmail: user.email,
                          playStoreConfigured: _isDeveloper,
                          isDeveloper: _isDeveloper,
                        ),
                      );
                    },
            ),
            if (needsPlayStore && !isSuccessful)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Coche la case ci-dessus pour valider',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ),
            if (isSuccessful) ...[
              const SizedBox(height: 16),
              Text(
                'Bienvenue dans l\'équipe !\n'
                'Tes apps pourront être testées par la communauté.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    required this.active,
    required this.done,
  });

  final int number;
  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = done
        ? Colors.green
        : active
        ? colors.primary
        : Colors.grey.shade300;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? colors.primary : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _StepText extends StatelessWidget {
  const _StepText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }
}
