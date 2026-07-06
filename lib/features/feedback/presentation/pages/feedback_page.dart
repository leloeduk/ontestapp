import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/feedback_bloc.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Suggestion')),
      body: BlocConsumer<FeedbackBloc, FeedbackState>(
        listener: (context, state) {
          if (state.status == FeedbackStatus.success) {
            _controller.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Merci pour ta suggestion !'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == FeedbackStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(
                  state.errorMessage ?? 'Erreur lors de l\'envoi')),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Icon(Icons.feedback_outlined,
                        size: 80, color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Tu as une suggestion ?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Partage ton idée pour améliorer l\'application.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _controller,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText:
                            'Décris ta suggestion...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez écrire un message';
                        }
                        if (value.trim().length < 10) {
                          return 'Minimum 10 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Envoyer',
                      icon: Icons.send_rounded,
                      isLoading: state.status == FeedbackStatus.submitting,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        final user =
                            context.read<AuthBloc>().state.user;
                        context.read<FeedbackBloc>().add(
                              FeedbackSubmitted(
                                userId: user.uid,
                                userName: user.name,
                                userEmail: user.email,
                                message: _controller.text.trim(),
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
