import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/onboarding_bloc.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _accepted = false;

  void _continue() {
    if (!_accepted) return;
    context.read<OnboardingBloc>().add(const OnboardingTermsAccepted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d\'utilisation')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue sur OnTestApp',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'En utilisant cette application, tu acceptes les '
                        'conditions suivantes :',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        icon: Icons.group_rounded,
                        title: 'Groupe de testeurs',
                        description:
                            'Tu dois rejoindre le Google Group '
                            'ontestapps@googlegroups.com pour participer. '
                            'Ce groupe permet de coordonner les tests '
                            'entre développeurs et testeurs.',
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        icon: Icons.smartphone_rounded,
                        title: "Tests d'applications",
                        description:
                            'Tu peux soumettre tes propres applications '
                            "pour qu'elles soient testées, et tester "
                            'celles des autres membres. Chaque test '
                            'rapporte des points.',
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Confidentialité',
                        description:
                            "Les captures d'écran et informations "
                            'partagées lors des tests sont visibles '
                            "par l'équipe d'administration uniquement "
                            'dans le cadre de la validation.',
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        icon: Icons.star_rounded,
                        title: 'Points et récompenses',
                        description:
                            'Les points sont crédités après validation '
                            'de tes tests par un administrateur. '
                            'Ils ne sont pas monnayables et peuvent '
                            "être ajustés en cas d'abus.",
                      ),
                    ],
                  ),
                ),
              ),
              CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                title: const Text(
                  "J'accepte les conditions d'utilisation "
                  'et la charte du groupe OnTestApp',
                  style: TextStyle(fontSize: 14),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _accepted ? _continue : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuer'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.onPrimaryContainer, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
