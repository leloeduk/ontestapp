import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/presentation/pages/about_page.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/services/user_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/earn/presentation/bloc/earn_bloc.dart';
import '../../features/earn/presentation/pages/earn_page.dart';
import '../../features/feedback/data/services/feedback_service.dart';
import '../../features/feedback/presentation/bloc/feedback_bloc.dart';
import '../../features/feedback/presentation/pages/feedback_page.dart';
import '../../features/group/presentation/bloc/group_bloc.dart';
import '../../features/group/presentation/pages/join_group_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/rewards/presentation/bloc/rewards_bloc.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';
import '../../features/test/data/repositories/review_repository.dart';
import '../../features/test/data/repositories/test_repository.dart';
import '../../features/test/domain/entities/test_app.dart';
import '../../features/test/presentation/bloc/admin_validation_bloc.dart';
import '../../features/test/presentation/bloc/review_bloc.dart';
import '../../features/test/presentation/bloc/test_detail_bloc.dart';
import '../../features/test/presentation/bloc/add_test_bloc.dart';
import '../../features/test/presentation/bloc/edit_test_bloc.dart';
import '../../features/test/presentation/pages/add_test_page.dart';
import '../../features/test/presentation/pages/edit_test_page.dart';
import '../../features/test/presentation/pages/admin_validation_page.dart';
import '../../features/test/presentation/pages/confirmation_page.dart';
import '../../features/test/presentation/pages/review_page.dart';
import '../../features/test/presentation/pages/test_detail_page.dart';
import '../../features/test/presentation/pages/test_in_progress_page.dart';

/// Configuration de la navigation (GoRouter).
class AppRouter {
  AppRouter._();

  static GoRouter createRouter({
    required AuthBloc authBloc,
    required OnboardingBloc onboardingBloc,
  }) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _RouterRefresh([
        authBloc.stream,
        onboardingBloc.stream,
      ]),
      redirect: (context, state) {
        final authStatus = authBloc.state.status;
        final onboardingStatus = onboardingBloc.state.status;
        final loc = state.matchedLocation;

        // En attente des informations initiales.
        if (authStatus == AuthStatus.unknown ||
            onboardingStatus == OnboardingStatus.unknown) {
          return loc == '/splash' ? null : '/splash';
        }

        final loggingIn = loc == '/sign-in' || loc == '/sign-up';

        if (authStatus == AuthStatus.unauthenticated) {
          return loggingIn ? null : '/sign-in';
        }

        // Utilisateur authentifié.
        if (onboardingStatus != OnboardingStatus.seen) {
          return loc == '/onboarding' ? null : '/onboarding';
        }
        if (!authBloc.state.user.joinedGroup) {
          return loc == '/join-group' ? null : '/join-group';
        }

        // Tout est en ordre : quitter les écrans d'entrée.
        if (loggingIn ||
            loc == '/splash' ||
            loc == '/onboarding' ||
            loc == '/join-group') {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/sign-in', builder: (_, __) => const SignInPage()),
        GoRoute(path: '/sign-up', builder: (_, __) => const SignUpPage()),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/join-group',
          builder: (context, __) => BlocProvider(
            create: (ctx) =>
                GroupBloc(authRepository: ctx.read<AuthRepository>()),
            child: const JoinGroupPage(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, __) => BlocProvider(
            create: (ctx) =>
                HomeBloc(testRepository: ctx.read<TestRepository>()),
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: '/test/:id',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (ctx) =>
                    TestDetailBloc(testRepository: ctx.read<TestRepository>())
                      ..add(TestDetailRequested(state.pathParameters['id']!)),
              ),
              BlocProvider(
                create: (ctx) =>
                    EditTestBloc(testRepository: ctx.read<TestRepository>()),
              ),
            ],
            child: const TestDetailPage(),
          ),
        ),
        GoRoute(
          path: '/test/:id/edit',
          builder: (context, state) {
            final test = state.extra as TestApp?;
            if (test == null) return const _MissingTest();
            return BlocProvider(
              create: (ctx) =>
                  EditTestBloc(testRepository: ctx.read<TestRepository>()),
              child: EditTestPage(test: test),
            );
          },
        ),
        GoRoute(
          path: '/test/:id/progress',
          builder: (context, state) {
            final test = state.extra as TestApp?;
            if (test == null) return const _MissingTest();
            return TestInProgressPage(test: test);
          },
        ),
        GoRoute(
          path: '/test/:id/review',
          builder: (context, state) {
            final test = state.extra as TestApp?;
            if (test == null) return const _MissingTest();
            return BlocProvider(
              create: (ctx) =>
                  ReviewBloc(reviewRepository: ctx.read<ReviewRepository>()),
              child: ReviewPage(test: test),
            );
          },
        ),
        GoRoute(
          path: '/test/:id/confirmation',
          builder: (_, __) => const ConfirmationPage(),
        ),
        GoRoute(
          path: '/admin/validation',
          builder: (context, __) => BlocProvider(
            create: (ctx) => AdminValidationBloc(
              reviewRepository: ctx.read<ReviewRepository>(),
            ),
            child: const AdminValidationPage(),
          ),
        ),
        // passe l'ID de l'utilisateur actuel à la page RewardsPage
        GoRoute(
          path: '/rewards',
          builder: (context, __) => BlocProvider<RewardsBloc>(
            create: (ctx) {
              final userId = ctx.read<AuthBloc>().state.user.uid;
              return RewardsBloc(reviewRepository: ctx.read<ReviewRepository>())
                ..add(RewardsRequested(userId));
            },
            child: RewardsPage(
              userId: context.read<AuthBloc>().state.user.uid,
            ), // Passe l'ID de l'utilisateur actuel
          ),
        ),
        GoRoute(
          path: '/add-test',
          builder: (context, __) => BlocProvider(
            create: (ctx) => AddTestBloc(
              testRepository: ctx.read<TestRepository>(),
              userService: ctx.read<UserService>(),
            ),
            child: const AddTestPage(),
          ),
        ),
        GoRoute(
          path: '/earn',
          builder: (context, __) => BlocProvider(
            create: (ctx) => EarnBloc(userService: ctx.read<UserService>()),
            child: const EarnPage(),
          ),
        ),
        GoRoute(
          path: '/about',
          builder: (_, __) => const AboutPage(),
        ),
        GoRoute(
          path: '/feedback',
          builder: (context, __) => BlocProvider(
            create: (ctx) => FeedbackBloc(
              feedbackService: FeedbackService(),
            ),
            child: const FeedbackPage(),
          ),
        ),
      ],
    );
  }
}

/// Rafraîchit le routeur quand l'un des Blocs émet un nouvel état.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(List<Stream<dynamic>> streams) {
    for (final stream in streams) {
      _subscriptions.add(stream.listen((_) => notifyListeners()));
    }
  }

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}

/// Écran de repli si le test n'a pas été transmis à la route.
class _MissingTest extends StatelessWidget {
  const _MissingTest();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: TextButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          child: const Text('Retour à l\'accueil'),
        ),
      ),
    );
  }
}
