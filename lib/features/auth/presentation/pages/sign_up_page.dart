import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/connectivity_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../onboarding/data/services/onboarding_service.dart';
import '../bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accepte les conditions d\'utilisation')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.read<OnboardingService>().acceptTerms();
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (_) => const _SignUpTermsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<ConnectivityCubit, bool>(
              builder: (context, isConnected) {
                if (!isConnected) return const OfflineBanner();
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: Center(
                child: BlocConsumer<AuthBloc, AuthState>(
                  listenWhen: (p, c) => p.errorMessage != c.errorMessage,
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                            SnackBar(content: Text(state.errorMessage!)));
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Créer un compte',
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rejoins la communauté et gagne des points.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            AppTextField(
                              controller: _nameController,
                              label: 'Nom',
                              prefixIcon: Icons.person_outline,
                              validator: (v) =>
                                  Validators.notEmpty(v, field: 'Le nom'),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Mot de passe',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              validator: Validators.password,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: _termsAccepted,
                                  onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                                    child: const Text(
                                      'J\'accepte les conditions d\'utilisation',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _showTerms,
                                  child: const Text('Lire', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AppButton(
                              label: 'S\'inscrire',
                              isLoading: state.submitting,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Déjà un compte ?'),
                                TextButton(
                                  onPressed: () => context.go('/sign-in'),
                                  child: const Text('Se connecter'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpTermsDialog extends StatelessWidget {
  const _SignUpTermsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conditions d\'utilisation'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bienvenue sur OnTestApp',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'En utilisant cette application, tu acceptes les conditions suivantes :',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            _SignUpConditionSection(
              icon: Icons.group_rounded,
              title: 'Groupe de testeurs',
              description:
                  'Tu dois rejoindre le Google Group ontestapps@googlegroups.com '
                  'pour participer. Ce groupe permet de coordonner les tests '
                  'entre développeurs et testeurs.',
            ),
            SizedBox(height: 16),
            _SignUpConditionSection(
              icon: Icons.smartphone_rounded,
              title: 'Tests d\'applications',
              description:
                  'Tu peux soumettre tes propres applications pour qu\'elles '
                  'soient testées, et tester celles des autres membres. '
                  'Chaque test rapporte des points.',
            ),
            SizedBox(height: 16),
            _SignUpConditionSection(
              icon: Icons.privacy_tip_rounded,
              title: 'Confidentialité',
              description:
                  'Les captures d\'écran et informations partagées lors des tests '
                  'sont visibles par l\'équipe d\'administration uniquement '
                  'dans le cadre de la validation.',
            ),
            SizedBox(height: 16),
            _SignUpConditionSection(
              icon: Icons.star_rounded,
              title: 'Points et récompenses',
              description:
                  'Les points sont crédités après validation de tes tests '
                  'par un administrateur. Ils ne sont pas monnayables et '
                  'peuvent être ajustés en cas d\'abus.',
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

class _SignUpConditionSection extends StatelessWidget {
  const _SignUpConditionSection({
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.onPrimaryContainer, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(description,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
