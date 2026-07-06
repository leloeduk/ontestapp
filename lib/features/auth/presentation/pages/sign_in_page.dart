import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../../../core/services/connectivity_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../onboarding/data/services/onboarding_service.dart';
import '../bloc/auth_bloc.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
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
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (_) => const _TermsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          SnackBar(content: Text(state.errorMessage!)),
                        );
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
                              'Bienvenue !',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Connecte-toi pour continuer à tester des apps.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
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
                              label: 'Se connecter',
                              isLoading: state.submitting,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 16),
                            const Center(child: Text('ou connecte-toi avec')),
                            const SizedBox(height: 16),
                            SignInButton(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              Buttons.google,
                              text: 'Continuer avec Google',
                              textStyle: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                              onPressed: () => context.read<AuthBloc>().add(
                                const AuthGoogleSignInRequested(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Pas encore de compte ?'),
                                TextButton(
                                  onPressed: () => context.go('/sign-up'),
                                  child: const Text('Créer un compte'),
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

class _TermsDialog extends StatelessWidget {
  const _TermsDialog();

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
            _ConditionSection(
              icon: Icons.group_rounded,
              title: 'Groupe de testeurs',
              description:
                  'Tu dois rejoindre le Google Group ontestapps@googlegroups.com '
                  'pour participer. Ce groupe permet de coordonner les tests '
                  'entre développeurs et testeurs.',
            ),
            SizedBox(height: 16),
            _ConditionSection(
              icon: Icons.smartphone_rounded,
              title: 'Tests d\'applications',
              description:
                  'Tu peux soumettre tes propres applications pour qu\'elles '
                  'soient testées, et tester celles des autres membres. '
                  'Chaque test rapporte des points.',
            ),
            SizedBox(height: 16),
            _ConditionSection(
              icon: Icons.privacy_tip_rounded,
              title: 'Confidentialité',
              description:
                  'Les captures d\'écran et informations partagées lors des tests '
                  'sont visibles par l\'équipe d\'administration uniquement '
                  'dans le cadre de la validation.',
            ),
            SizedBox(height: 16),
            _ConditionSection(
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

class _ConditionSection extends StatelessWidget {
  const _ConditionSection({
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
