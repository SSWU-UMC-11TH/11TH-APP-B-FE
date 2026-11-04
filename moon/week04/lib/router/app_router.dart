import 'package:go_router/go_router.dart';

import '../data/movie_data.dart';

import '../screens/start_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/main_screen.dart';

import '../screens/my_page_screen.dart';

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

      // 회원가입
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // 홈
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(
          currentIndex: 0,
          child: HomeScreen(),
        ),
      ),

      // 영화 목록
      GoRoute(
        path: '/movies',
        builder: (context, state) => const MainScreen(
          currentIndex: 1,
          child: MovieListScreen(),
        ),
      ),
      // 마이 페이지
      GoRoute(
      path: '/mypage',
      builder: (context, state) => const MainScreen(
      currentIndex: 2,
      child: MyPageScreen(),
  ),
),
      // 영화 상세
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = int.tryParse(
            state.pathParameters['movieId'] ?? '',
          );

          final movie = mockMovies.firstWhere(
            (movie) => movie.id == movieId,
            orElse: () => mockMovies.first,
          );

          return MovieDetailScreen(
            movie: movie,
          );
        },
      ),
    ],
  );
}