import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/tmdb_client.dart';
import 'core/network/movie_log_client.dart';
import 'core/storage/token_storage.dart';
import 'data/services/tmdb_movie_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/member_api_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'view_models/auth_view_model.dart';

import 'view_models/current_rating_session.dart';
import 'data/services/favorite_api_service.dart';
import 'core/session/session_guard.dart';
import 'core/session/auth_session_bridge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final publicClient = createMovieLogClient();
    final tokenStorage = SecureTokenStorage(const FlutterSecureStorage());
    final authClient = createAuthMovieLogClient(tokenStorage);

    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<FavoriteApiService>(
          create: (_) => FavoriteApiService(authClient),
        ),
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        Provider<SignUpService>(create: (_) => SignUpService(publicClient)),

        Provider<RatingApiService>(
          create: (_) => RatingApiService(publicClient, authClient),
        ),

        Provider<AuthApiService>(create: (_) => AuthApiService(publicClient)),
        Provider<MemberApiService>(create: (_) => MemberApiService(authClient)),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
          ),
        ),

        Provider<AuthSessionBridge>(
          create: (context) {
            final auth = context.read<AuthViewModel>();

            return AuthSessionBridge(
              authSignals: auth,
              sessionVersion: () => auth.sessionVersion,
              verifiedEmail: () => auth.status == AuthStatus.signedIn
                  ? auth.member?.email
                  : null,
            );
          },
          dispose: (_, bridge) => bridge.dispose(),
        ),
        Provider<SessionGuard>(
          create: (context) => context.read<AuthSessionBridge>().guard,
        ),

        ChangeNotifierProvider<CurrentRatingSession>(
          create: (context) =>
              CurrentRatingSession(context.read<AuthViewModel>()),
        ),
      ],
      child: const _MovieLogRouterApp(),
    );
  }
}

class _MovieLogRouterApp extends StatefulWidget {
  const _MovieLogRouterApp();

  @override
  State<_MovieLogRouterApp> createState() => _MovieLogRouterAppState();
}

class _MovieLogRouterAppState extends State<_MovieLogRouterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    _router = AppRouter.createRouter(auth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) auth.restoreSession();
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
