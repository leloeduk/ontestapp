import 'package:flutter/material.dart';

class TermsReadPage extends StatelessWidget {
  const TermsReadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d\'utilisation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                color: colors,
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
                color: colors,
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
                color: colors,
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
                color: colors,
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
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final ColorScheme color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color.onPrimaryContainer, size: 24),
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
