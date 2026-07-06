import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/services/ad_service.dart';
import 'core/services/connectivity_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/data/services/user_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/data/services/onboarding_service.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/test/data/repositories/review_repository.dart';
import 'features/test/data/repositories/test_repository.dart';
import 'features/test/data/services/review_service.dart';
import 'features/test/data/services/storage_service.dart';
import 'features/test/data/services/test_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await AdService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Services
  final _userService = UserService();
  final _storageService = StorageService();

  // Repositories
  late final AuthRepository _authRepository = AuthRepository(
    authService: AuthService(),
    userService: _userService,
  );
  late final TestRepository _testRepository = TestRepository(
    testService: TestService(),
  );
  late final ReviewRepository _reviewRepository = ReviewRepository(
    reviewService: ReviewService(),
    userService: _userService,
    storageService: _storageService,
  );

  // Blocs globaux (nécessaires au routeur)
  late final AuthBloc _authBloc = AuthBloc(authRepository: _authRepository);
  late final OnboardingBloc _onboardingBloc =
      OnboardingBloc(service: OnboardingService());
  late final ConnectivityCubit _connectivityCubit = ConnectivityCubit();

  late final GoRouter _router = AppRouter.createRouter(
    authBloc: _authBloc,
    onboardingBloc: _onboardingBloc,
  );

  @override
  void dispose() {
    _authBloc.close();
    _onboardingBloc.close();
    _connectivityCubit.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _testRepository),
        RepositoryProvider.value(value: _reviewRepository),
        RepositoryProvider.value(value: _userService),
        RepositoryProvider.value(value: _storageService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _onboardingBloc),
          BlocProvider.value(value: _connectivityCubit),
        ],
        child: MaterialApp.router(
          title: 'OnTestApp',
          theme: AppTheme.lightTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
