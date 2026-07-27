import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/services/ad_service.dart';
import 'core/services/connectivity_cubit.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/update_service.dart';
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

  final pushService = PushNotificationService();
  await pushService.init();

  runApp(MyApp(pushService: pushService));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.pushService});

  final PushNotificationService pushService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Services
  final _userService = UserService();
  final _storageService = StorageService();
  final _onboardingService = OnboardingService();
  final _updateService = UpdateService();
  late final _pushService = widget.pushService;
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _updateChecked = false;

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

  // Localisation
  late final LocaleCubit _localeCubit = LocaleCubit();

  // Blocs globaux (nécessaires au routeur)
  late final AuthBloc _authBloc = AuthBloc(
    authRepository: _authRepository,
    localeCubit: _localeCubit,
  );
  late final OnboardingBloc _onboardingBloc =
      OnboardingBloc(service: _onboardingService);
  late final ConnectivityCubit _connectivityCubit = ConnectivityCubit();

  late final GoRouter _router = AppRouter.createRouter(
    navigatorKey: _navigatorKey,
    authBloc: _authBloc,
    onboardingBloc: _onboardingBloc,
    localeCubit: _localeCubit,
  );

  @override
  void initState() {
    super.initState();

    _pushService.onForegroundMessage = _onForegroundPush;

    _authBloc.stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user.uid.isNotEmpty) {
        _pushService.saveToken(state.user.uid);
      }
    });

    if (_authBloc.state.status == AuthStatus.authenticated &&
        _authBloc.state.user.uid.isNotEmpty) {
      _pushService.saveToken(_authBloc.state.user.uid);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  void _onForegroundPush(RemoteMessage message) {
    final body = message.data['body'] ?? '';
    if (body.isEmpty) return;

    final navCtx = _navigatorKey.currentContext;
    if (navCtx == null || !navCtx.mounted) return;

    ScaffoldMessenger.of(navCtx).showSnackBar(
      SnackBar(
        content: Text(body),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _localeCubit.close();
    _authBloc.close();
    _onboardingBloc.close();
    _connectivityCubit.close();
    _router.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    if (_updateChecked) return;
    _updateChecked = true;

    final available = await _updateService.isUpdateAvailable();
    if (!available || !mounted) return;

    final tr = AppLocalizations(_localeCubit.state);
    if (!mounted) return;

    final navCtx = _navigatorKey.currentContext;
    if (navCtx == null || !navCtx.mounted) return;

    showDialog<void>(
      context: navCtx,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.system_update_rounded,
            size: 48, color: Theme.of(ctx).colorScheme.primary),
        title: Text(tr.updateAvailable),
        content: Text(tr.newVersionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.later),
          ),
          FilledButton.icon(
            onPressed: () {
              launchUrl(
                Uri.parse(AppConstants.playStoreUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            label: Text(tr.updateNow),
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
    );
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
        RepositoryProvider.value(value: _onboardingService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _localeCubit),
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _onboardingBloc),
          BlocProvider.value(value: _connectivityCubit),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              locale: locale,
              title: 'OnTestApp',
              theme: AppTheme.lightTheme,
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
