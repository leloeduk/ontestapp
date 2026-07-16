import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/connectivity_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../onboarding/data/services/onboarding_service.dart';
import '../../../onboarding/presentation/pages/terms_read_page.dart';
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

  void _googleSignIn() {
    context.read<OnboardingService>().acceptTerms();
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
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
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  tr.welcome,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tr.signInSubtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                AppTextField(
                                  controller: _emailController,
                                  label: tr.email,
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => Validators.email(v, context),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _passwordController,
                                  label: tr.password,
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (v) => Validators.password(v, context),
                                ),
                                const SizedBox(height: 4),
                                CheckboxListTile(
                                  value: _termsAccepted,
                                  onChanged: (v) =>
                                      setState(() => _termsAccepted = v!),
                                  title: Text(
                                    tr.acceptTerms,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                                    child: TextButton(
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TermsReadPage(),
                                        ),
                                      ),
                                      child: Text(
                                        tr.readTerms,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                AppButton(
                                  label: tr.signIn,
                                  isLoading: state.submitting,
                                  onPressed:
                                      _termsAccepted ? _submit : null,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  tr.signInTermsMsg,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        tr.or,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SignInButton(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  Buttons.google,
                                  text: tr.continueWithGoogle,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                  onPressed:
                                      _termsAccepted ? _googleSignIn : () {},
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tr.noAccount,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/sign-up'),
                                      child: Text(tr.signUp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state.submitting)
                          Container(
                            color: Colors.black26,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
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
