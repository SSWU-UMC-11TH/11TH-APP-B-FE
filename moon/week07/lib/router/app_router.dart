import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/movie_data.dart';
import '../data/services/tmdb_movie_service.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/rating_api_service.dart';

import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/sign_up_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/learning_member_session.dart';

import '../screens/start_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/main_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/my_ratings_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 시작 화면
      GoRoute(
        path: '/',
        builder: (context, state) => const StartScreen(),
      ),

      // 7주차: 닉네임·이메일 중복 확인 및 회원가입 POST
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

      // 홈: TMDB 인기 영화 조회
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

      // 영화 목록: TMDB 장르 및 Discover API
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

      // 마이페이지
      GoRoute(
        path: '/mypage',
        builder: (context, state) => const MainScreen(
          currentIndex: 2,
          child: MyPageScreen(),
        ),
      ),

      // 7주차: 회원가입으로 발급받은 ID의 평점 조회
      GoRoute(
        path: '/mypage/ratings',
        builder: (context, state) {
          final memberId =
              context.read<LearningMemberSession>().memberId;

          // 학습용 회원가입을 아직 하지 않은 경우
          if (memberId == null) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('내가 등록한 평점'),
              ),
              body: const Center(
                child: Text('학습용 회원가입이 필요합니다.'),
              ),
            );
          }

          return ChangeNotifierProvider<MyRatingsViewModel>(
            create: (context) => MyRatingsViewModel(
              context.read<RatingApiService>(),
              context.read<TmdbMovieService>(),
              memberId,
            )..loadRatings(),
            child: const MyRatingsScreen(),
          );
        },
      ),

      // 기존 4주차 Mock 영화 상세 화면
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = int.tryParse(
            state.pathParameters['movieId'] ?? '',
          );

          final matches = mockMovies.where(
            (movie) => movie.id == movieId,
          );

          // 잘못된 영화 ID가 전달된 경우
          if (matches.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text('존재하지 않는 영화입니다.'),
              ),
            );
          }

          return MovieDetailScreen(
            movie: matches.first,
          );
        },
      ),
    ],
  );
}
