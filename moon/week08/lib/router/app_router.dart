import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/movie_data.dart';
import '../data/services/tmdb_movie_service.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/rating_api_service.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/sign_up_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/main_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/my_ratings_screen.dart';

import '../view_models/edit_profile_view_model.dart';
import '../data/services/member_api_service.dart';
import '../screens/edit_profile_screen.dart';

import '../view_models/current_rating_session.dart';



String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/signup'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    AuthStatus.initializing ||
    AuthStatus.retryRequired =>
      atStart ? null : '/start',
    AuthStatus.signedOut ||
    AuthStatus.authenticating =>
      atPublic ? null : '/login',
    AuthStatus.signedIn =>
      (atStart || atPublic) ? '/home' : null,
  };
}

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel auth) {
    return GoRouter(
      initialLocation: '/start',
      navigatorKey: rootNavigatorKey,
      refreshListenable: auth,
      redirect: (context, state) {
        return authRedirect(auth.status, state.uri.path);
      },
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) {
            final currentAuth = context.watch<AuthViewModel>();
            return SplashScreen(
              message: currentAuth.message,
              onRetry: currentAuth.status == AuthStatus.retryRequired
                  ? currentAuth.restoreSession
                  : null,
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) =>
              ChangeNotifierProvider<SignUpViewModel>(
            create: (context) => SignUpViewModel(
              context.read<SignUpService>(),
            ),
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              ChangeNotifierProvider<MovieHomeViewModel>(
            create: (context) => MovieHomeViewModel(
              context.read<TmdbMovieService>(),
            )..loadPopular(),
            child: const MainScreen(
              currentIndex: 0,
              child: HomeScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/movies',
          builder: (context, state) =>
              ChangeNotifierProvider<MovieListViewModel>(
            create: (context) => MovieListViewModel(
              context.read<TmdbMovieService>(),
            )..loadInitial(),
            child: const MainScreen(
              currentIndex: 1,
              child: MovieListScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/mypage',
          builder: (context, state) => const MainScreen(
            currentIndex: 2,
            child: MyPageScreen(),
          ),
        ),

        GoRoute(
          path: '/mypage/profile/edit',
          builder: (context, state) {
            final auth = context.watch<AuthViewModel>();

            if (auth.member == null) {
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text('프로필 수정'),
                ),
                body: Center(
                  child: auth.memberStatus == MemberLoadStatus.error
                      ? ElevatedButton(
                          onPressed: () => auth.loadMember(force: true),
                          child: const Text('다시 시도'),
                        )
                      : const CircularProgressIndicator(),
                ),
              );
            }

            return ChangeNotifierProvider<EditProfileViewModel>(
              create: (context) => EditProfileViewModel(
                context.read<MemberApiService>(),
                auth,
              ),
              child: const EditProfileScreen(),
            );
          },
        ),

          GoRoute(
            path: '/mypage/ratings',
            builder: (context, state) {
              return ChangeNotifierProvider<MyRatingsViewModel>(
                create: (context) => MyRatingsViewModel(
                  context.read<RatingApiService>(),
                  context.read<TmdbMovieService>(),
                  context.read<CurrentRatingSession>(),
                  context.read<AuthViewModel>(),
                )..loadRatings(),
              child: const MyRatingsScreen(),
            );
          },
        ),

        GoRoute(
          path: '/movies/:movieId',
          builder: (context, state) {
            final movieId = int.tryParse(
              state.pathParameters['movieId'] ?? '',
            );
            final matches = mockMovies.where(
              (movie) => movie.id == movieId,
            );
            if (matches.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text('존재하지 않는 영화입니다.'),
                ),
              );
            }
            return MovieDetailScreen(movie: matches.first);
          },
        ),
      ],
    );
  }
}
