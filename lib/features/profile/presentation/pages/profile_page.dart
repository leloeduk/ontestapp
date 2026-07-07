import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/app_status_widgets.dart';
import '../../../auth/data/services/user_service.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../test/data/models/review_model.dart';
import '../../../test/data/repositories/review_repository.dart';
import '../../../../core/widgets/app_text_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<ReviewModel>? _reviews;
  bool _loading = false;
  DateTime? _lastLoad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReviews());
  }

  Future<void> _loadReviews() async {
    if (_loading) return;
    _loading = true;
    _lastLoad = DateTime.now();
    final uid = context.read<AuthBloc>().state.user.uid;
    try {
      final reviews =
          await context.read<ReviewRepository>().getReviewsByUser(uid);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Veux-tu vraiment te déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_reviews != null && !_loading &&
        DateTime.now().difference(_lastLoad ?? DateTime(0)).inSeconds > 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadReviews());
    }
    final user = context.watch<AuthBloc>().state.user;
    final colors = Theme.of(context).colorScheme;

    final validatedCount =
        _reviews?.where((r) => r.testValidated).length ?? 0;
    final pendingCount =
        _reviews?.where((r) => !r.testValidated).length ?? 0;
    final validPoints = _reviews
            ?.where((r) => r.testValidated)
            .fold<int>(0, (sum, r) => sum + r.rewardPoints) ??
        0;

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage:
                      (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                  child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 36,
                            color: colors.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
                if (user.isAdmin)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showEditDialog(context, user),
                  child: Icon(Icons.edit, size: 18, color: colors.primary),
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              user.email,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _InfoCard(
                icon: Icons.emoji_events_rounded,
                label: 'Points',
                value: '${user.points}',
                color: colors.primary,
              ),
              const SizedBox(width: 12),
              _InfoCard(
                icon: Icons.check_circle_rounded,
                label: 'Tests réalisés',
                value: '${user.testsDone}',
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoCard(
                icon: Icons.verified_rounded,
                label: 'Validés',
                value: '$validatedCount',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _InfoCard(
                icon: Icons.hourglass_empty_rounded,
                label: 'En attente',
                value: '$pendingCount',
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoCard(
                icon: Icons.payments_rounded,
                label: 'Total gagné',
                value: '+$validPoints pts',
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 12),
              _InfoCard(
                icon: Icons.card_membership_rounded,
                label: 'Plan',
                value: user.plan == 'free' ? 'Gratuit' : user.plan,
                color: Colors.blue,
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/rewards'),
              icon: const Icon(Icons.history_rounded),
              label: const Text('Voir mon historique complet'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Changer de plan'),
                  content: const Text(
                    'Pas disponible pour l\'instant. '
                    'Bientôt disponible.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.star_rounded),
              label: const Text('Changer de plan'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: LoadingView(),
            )
          else if (_reviews != null && _reviews!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Dernières soumissions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_reviews!.take(5).map(
              (review) => _SubmissionTile(review: review),
            )),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: colors.error,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

  Future<void> _showEditDialog(BuildContext context, AppUser user) async {
    final nameCtl = TextEditingController(text: user.name);
    String? newPhotoUrl = user.photoUrl;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameCtl,
              label: 'Nom',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (picked != null) {
                    final userService = ctx.read<UserService>();
                    final uid = ctx.read<AuthBloc>().state.user.uid;
                    newPhotoUrl = await userService.uploadUserImage(
                      uid: uid,
                      filePath: picked.path,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  newPhotoUrl != null
                      ? 'Changer la photo'
                      : 'Ajouter une photo',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (submitted == true && context.mounted) {
      context.read<AuthBloc>().add(AuthUpdateProfileRequested(
            name: nameCtl.text.trim(),
            photoUrl: newPhotoUrl,
          ));
    }
  }

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  const _SubmissionTile({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          review.testValidated
              ? Icons.check_circle_rounded
              : Icons.hourglass_empty_rounded,
          color:
              review.testValidated ? Colors.green : Colors.orange,
          size: 28,
        ),
        title: Text(
          review.testName ?? 'Test',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          review.testValidated ? 'Validé (+${review.rewardPoints} pts)' : 'En attente de validation',
          style: TextStyle(
            fontSize: 12,
            color: review.testValidated ? Colors.green : Colors.orange,
          ),
        ),
        trailing: review.testValidated
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${review.rewardPoints}',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
