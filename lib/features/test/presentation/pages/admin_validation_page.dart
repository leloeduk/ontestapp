import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_status_widgets.dart';
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

  Future<void> _confirmBatchValidate() async {
    final tr = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.validateSubmission),
        content: Text(tr.pointsWillBeCredited),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.cancel),
          ),
          AppButton(
            label: tr.validate,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminValidationBloc>().add(const AdminBatchValidate());
    }
  }

  Future<void> _confirmBatchDelete() async {
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
      context.read<AdminValidationBloc>().add(const AdminBatchDelete());
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

          return Column(
            children: [
              if (state.selectedIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withAlpha(100),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${state.selectedIds.length} sélectionné(s)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: state.status == AdminValidationStatus.validating ||
                                state.status == AdminValidationStatus.deleting
                            ? null
                            : _confirmBatchValidate,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(tr.validate),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: state.status == AdminValidationStatus.validating ||
                                state.status == AdminValidationStatus.deleting
                            ? null
                            : _confirmBatchDelete,
                        icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                        label: Text(tr.delete),
                        style: TextButton.styleFrom(foregroundColor: colors.error),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.reviews.length,
                  itemBuilder: (_, i) {
                    final review = state.reviews[i];
                    final isSelected = state.selectedIds.contains(review.id);
                    final isDeleting = state.status == AdminValidationStatus.deleting;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: isDeleting
                                      ? null
                                      : (_) => context
                                          .read<AdminValidationBloc>()
                                          .add(AdminToggleReview(review.id)),
                                ),
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
                                      Text(
                                        'ID: ${review.userId}',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _StatusBadge(validated: review.testValidated),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${state.userTestsCount[review.userId] ?? 0}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      tr.testCountPlural,
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
                                      Text(
                                        '${review.rewardPoints} pts',
                                        style: TextStyle(
                                          color: colors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
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
                            if (!review.testValidated) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: isDeleting
                                          ? null
                                          : () => _validate(review),
                                      icon: Icon(Icons.check_circle_outline,
                                          size: 18, color: colors.primary),
                                      label: Text(
                                          '${tr.validate} (+${review.rewardPoints} ${tr.points})'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<AdminValidationBloc, AdminValidationState>(
        builder: (context, state) {
          if (state.reviews.isEmpty || state.status == AdminValidationStatus.loading) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.small(
            onPressed: () {
              if (state.allSelected) {
                context.read<AdminValidationBloc>().add(const AdminDeselectAll());
              } else {
                context.read<AdminValidationBloc>().add(const AdminSelectAll());
              }
            },
            tooltip: state.allSelected ? 'Tout désélectionner' : 'Tout sélectionner',
            child: Icon(state.allSelected ? Icons.deselect : Icons.select_all),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.validated});

  final bool validated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: validated
            ? Colors.green.withAlpha(30)
            : Colors.orange.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        validated ? 'Validé' : 'En attente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: validated ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}
