import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/test_app.dart';
import '../bloc/review_bloc.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.test});

  final TestApp test;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final uid = context.read<AuthBloc>().state.user.uid;
    context.read<ReviewBloc>().add(
          ReviewSubmitted(
            userId: uid,
            testId: widget.test.id,
            rating: _rating,
            comment: _commentController.text.trim(),
            rewardPoints: 10,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ton avis')),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state.status == ReviewStatus.success) {
            context.go(
              '/test/${widget.test.id}/confirmation',
              extra: 10,
            );
          } else if (state.status == ReviewStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Erreur')),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Comment as-tu trouvé ${widget.test.title} ?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40,
                      itemBuilder: (_, __) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) =>
                          setState(() => _rating = value),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _commentController,
                    label: 'Commentaire (optionnel)',
                    hint: 'Partage ton expérience...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Envoyer mon avis',
                    isLoading: state.status == ReviewStatus.submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
