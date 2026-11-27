import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/tmdb_movie_dto.dart';
import 'package:flutter_application_1/data/services/member_check_service.dart';
import 'package:flutter_application_1/data/services/rating_api_service.dart';
import 'package:flutter_application_1/data/services/tmdb_movie_service.dart';
import 'package:flutter_application_1/view_models/movie_home_view_model.dart';
import 'package:flutter_application_1/view_models/movie_list_view_model.dart';
import 'package:flutter_application_1/view_models/my_ratings_view_model.dart';
import 'package:flutter_application_1/view_models/sign_up_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screen/start_screen.dart';
import '../screen/sign_up_screen.dart';
import '../screen/main_screen.dart';
import '../screen/home_screen.dart';
import '../screen/movie_list_screen.dart';
import '../screen/movie_detail_screen.dart';
import '../screen/my_page_screen.dart';
import '../screen/my_ratings_screen.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/start',
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
          create: (context) =>
              SignUpViewModel(context.read<MemberCheckService>()),
          child: const SignUpScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: _indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                ChangeNotifierProvider<MovieHomeViewModel>(
              create: (context) => MovieHomeViewModel(
                context.read<TmdbMovieService>(),
              )..loadPopular(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) =>
                ChangeNotifierProvider<MovieListViewModel>(
              create: (context) => MovieListViewModel(
                context.read<TmdbMovieService>(),
              )..loadInitial(),
              child: const MovieListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':movieId',
                builder: (context, state) {
                  // 목록에서 넘겨준 TMDB 영화 데이터
                  final movie = state.extra as TmdbMovieDto?;

                  if (movie == null) {
                    return Scaffold(
                      appBar: AppBar(),
                      body: const Center(child: Text('영화를 찾을 수 없습니다.')),
                    );
                  }
                  return MovieDetailScreen(movie: movie);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const MyPageScreen(),
            routes: [
              GoRoute(
                path: 'ratings', // 최종 경로: /my/ratings
                parentNavigatorKey: rootNavigatorKey, // 하단 NavigationBar를 가림
                builder: (context, state) =>
                    ChangeNotifierProvider<MyRatingsViewModel>(
                  create: (context) => MyRatingsViewModel(
                    context.read<RatingApiService>(),
                    context.read<TmdbMovieService>(),
                    sampleMemberId, // 6주차는 학습용 ID 1입니다.
                  )..load(),
                  child: const MyRatingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static int _indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}