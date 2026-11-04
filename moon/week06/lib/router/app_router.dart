
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/movie_data.dart';
import '../data/services/tmdb_movie_service.dart';
import '../data/services/member_check_service.dart';

import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/sign_up_view_model.dart';

import '../screens/start_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/main_screen.dart';
import '../screens/my_page_screen.dart';

import '../data/services/rating_api_service.dart';
import '../view_models/my_ratings_view_model.dart';
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

      // 회원가입 - 6주차 중복 확인 ViewModel 연결
      GoRoute(
        path: '/signup',
        builder: (context, state) =>
            ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(
            context.read<MemberCheckService>(),
          ),
          child: const SignUpScreen(),
        ),
      ),

      // 홈 - TMDB Popular API
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

      // 영화 목록 - TMDB Genre / Discover API
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

            // 6주차: 내가 등록한 평점
      GoRoute(
        path: '/mypage/ratings',
        builder: (context, state) =>
            ChangeNotifierProvider<MyRatingsViewModel>(
          create: (context) => MyRatingsViewModel(
            context.read<RatingApiService>(),
            context.read<TmdbMovieService>(),
          )..loadRatings(memberId: 1),
          child: const MyRatingsScreen(),
        ),
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

          // 유효하지 않은 ID로 잘못된 영화가 표시되는 문제 방지
          if (matches.isEmpty) {
            throw Exception('존재하지 않는 영화입니다.');
          }

          return MovieDetailScreen(
            movie: matches.first,
          );
        },
      ),
    ],
  );
}
