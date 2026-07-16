import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/connectivity_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../onboarding/data/services/onboarding_service.dart';
import '../../../onboarding/presentation/pages/terms_read_page.dart';
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
  bool _termsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_termsAccepted) {
      setState(() => _termsError = true);
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

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
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
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_add_rounded,
                                    size: 36,
                                    color: colors.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  tr.createAccount,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tr.signUpSubtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                AppTextField(
                                  controller: _nameController,
                                  label: tr.name,
                                  prefixIcon: Icons.person_outline,
                                  validator: (v) => Validators.notEmpty(
                                    v,
                                    context: context,
                                    field: tr.nameField,
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                  onChanged: (v) => setState(() {
                                    _termsAccepted = v!;
                                    _termsError = false;
                                  }),
                                  title: Text(
                                    tr.acceptTerms,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                if (_termsError)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                                    child: Text(
                                      tr.acceptTermsRequired,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 12),
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const TermsReadPage(),
                                      ),
                                    ),
                                    child: Text(
                                      tr.readTermsShort,
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                AppButton(
                                  label: tr.signUp,
                                  isLoading: state.submitting,
                                  onPressed: _submit,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  tr.signUpTermsMsg,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tr.alreadyAccount,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/sign-in'),
                                      child: Text(tr.signIn),
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
