import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/tmdb_movie_dto.dart';
import 'package:flutter_application_1/data/services/rating_api_service.dart';
import 'package:flutter_application_1/data/services/sign_up_service.dart';
import 'package:flutter_application_1/data/services/tmdb_movie_service.dart';
import 'package:flutter_application_1/view_models/learning_member_session.dart';
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
import '../screen/movie_detail_loader.dart';
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
          // 7주차: MemberCheckService → SignUpService
          create: (context) => SignUpViewModel(context.read<SignUpService>()),
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
                  // movieId는 URL 식별자(TmdbMovieDto.id)로만 씁니다.
                  final id =
                      int.tryParse(state.pathParameters['movieId'] ?? '');
                  if (id == null || id < 1) {
                    return Scaffold(
                      appBar: AppBar(),
                      body: const Center(child: Text('영화 ID가 올바르지 않습니다.')),
                    );
                  }
                  // extra가 없으면(직접 접근·Deep Link) Loader가 TMDB에서 다시 조회합니다.
                  final extra = state.extra;
                  return MovieDetailLoader(
                    movieId: id,
                    initialMovie:
                        extra is TmdbMovieDto && extra.id == id ? extra : null,
                  );
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
                builder: (context, state) {
                  // 6주차 sampleMemberId(1) 대신 회원가입 결과의 memberId를 사용합니다.
                  final id = context.read<LearningMemberSession>().memberId;
                  if (id == null) {
                    return Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        title: const Text('내가 등록한 평점'),
                      ),
                      body: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('학습용 회원가입이 필요합니다.'),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text('회원가입 하러 가기'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ChangeNotifierProvider<MyRatingsViewModel>(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      id,
                    )..load(),
                    child: const MyRatingsScreen(),
                  );
                },
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
