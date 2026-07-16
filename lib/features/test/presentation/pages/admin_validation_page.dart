import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_status_widgets.dart';
import '../../../test/data/repositories/test_repository.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/review_model.dart';
import '../bloc/admin_validation_bloc.dart';

class AdminValidationPage extends StatefulWidget {
  const AdminValidationPage({super.key});

  @override
  State<AdminValidationPage> createState() => _AdminValidationPageState();
}

class _AdminValidationPageState extends State<AdminValidationPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminValidationBloc>().add(const AdminValidationRequested());
  }

  Future<void> _openPlayStore(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        final tr = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr.couldNotOpenLink)),
        );
      }
    }
  }

  void _validate(ReviewModel review) {
    final tr = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.validateSubmission),
        content: Text(tr.pointsWillBeCredited),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.cancel),
          ),
          AppButton(
            label: tr.validate,
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminValidationBloc>().add(
                AdminValidateReview(
                  reviewId: review.id,
                  userId: review.userId,
                  rewardPoints: review.rewardPoints,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _viewImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              child: AppImage(
                imageUrl: url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTest(ReviewModel review) async {
    final tr = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteTestConfirm),
        content: Text(tr.deleteTestMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final storageService = context.read<StorageService>();
      await storageService.deleteFile(review.screenshot1Url);
      await storageService.deleteFile(review.screenshot2Url);
      if (mounted) {
        final testRepo = context.read<TestRepository>();
        final validationBloc = context.read<AdminValidationBloc>();
        await testRepo.deleteTest(review.testId);
        validationBloc.add(const AdminValidationRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr.adminValidationTitle)),
      body: BlocBuilder<AdminValidationBloc, AdminValidationState>(
        builder: (context, state) {
          if (state.status == AdminValidationStatus.loading ||
              state.status == AdminValidationStatus.idle) {
            return const LoadingView();
          }
          if (state.status == AdminValidationStatus.error) {
            return ErrorView(message: state.errorMessage ?? tr.errorLabel);
          }
          if (state.reviews.isEmpty) {
            return Center(child: Text(tr.noPendingSubmissions));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: state.reviews.length,
            itemBuilder: (_, i) {
              final review = state.reviews[i];
              final testsCount = state.userTestsCount[review.userId] ?? 0;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: colors.primaryContainer,
                            child: Text(
                              (review.userName ?? '?')[0].toUpperCase(),
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.userName ?? tr.userLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                if (review.testName != null)
                                  Text(
                                    review.testName!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$testsCount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                testsCount > 1 ? tr.testCountPlural : tr.testCount,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr.capture1,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _viewImage(review.screenshot1Url),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: review.screenshot1Url.startsWith('http')
                                        ? AppImage(
                                            imageUrl: review.screenshot1Url,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            borderRadius: 8,
                                          )
                                        : Container(
                                            height: 150,
                                            color: Colors.grey.shade200,
                                            child: Center(
                                              child: Text(tr.noCapture),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr.capture2,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _viewImage(review.screenshot2Url),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: review.screenshot2Url.startsWith('http')
                                        ? AppImage(
                                            imageUrl: review.screenshot2Url,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            borderRadius: 8,
                                          )
                                        : Container(
                                            height: 150,
                                            color: Colors.grey.shade200,
                                            child: Center(
                                              child: Text(tr.noCapture),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (review.playStoreUrl != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openPlayStore(review.playStoreUrl!),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: Text(tr.viewOnPlayStore),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _deleteTest(review),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: Text(tr.delete),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.error,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              label: '${tr.validate} (+${review.rewardPoints} ${tr.points})',
                              isLoading:
                                  state.status ==
                                  AdminValidationStatus.validating,
                              onPressed: () => _validate(review),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
