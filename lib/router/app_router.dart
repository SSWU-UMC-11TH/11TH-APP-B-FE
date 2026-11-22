import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/tmdb_movie_dto.dart';
import 'package:flutter_application_1/data/services/member_api_service.dart';
import 'package:flutter_application_1/data/services/rating_api_service.dart';
import 'package:flutter_application_1/data/services/sign_up_service.dart';
import 'package:flutter_application_1/data/services/tmdb_movie_service.dart';
import 'package:flutter_application_1/view_models/auth_view_model.dart';
import 'package:flutter_application_1/view_models/edit_profile_view_model.dart';
import 'package:flutter_application_1/view_models/movie_home_view_model.dart';
import 'package:flutter_application_1/view_models/movie_list_view_model.dart';
import 'package:flutter_application_1/view_models/my_ratings_view_model.dart';
import 'package:flutter_application_1/view_models/session_rating_store.dart';
import 'package:flutter_application_1/view_models/sign_up_view_model.dart';
import 'package:flutter_application_1/widgets/movielog_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screen/edit_profile_screen.dart';
import '../screen/home_screen.dart';
import '../screen/login_screen.dart';
import '../screen/main_screen.dart';
import '../screen/movie_detail_loader.dart';
import '../screen/movie_list_screen.dart';
import '../screen/my_page_screen.dart';
import '../screen/my_ratings_screen.dart';
import '../screen/sign_up_screen.dart';
import '../screen/splash_screen.dart';

/// 인증 상태별 화면 이동 규칙. redirect 안에서는 상태만 읽고 판단합니다. (API 호출 X)
String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    // 토큰 확인 중 또는 확인 실패(재시도 버튼): 스플래시 화면 유지
    AuthStatus.initializing || AuthStatus.retryRequired => atStart ? null : '/start',
    // 로그아웃 또는 로그인 요청 중: 공개 화면만 허용
    AuthStatus.signedOut || AuthStatus.authenticating => atPublic ? null : '/login',
    // 로그인됨: 스플래시와 로그인·회원가입 화면은 홈으로 보냄
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/start',
      navigatorKey: rootNavigatorKey,
      refreshListenable: authViewModel, // 인증 상태가 바뀌면 redirect를 다시 실행합니다.
      redirect: (context, state) =>
          authRedirect(authViewModel.status, state.uri.path),
      routes: [
        GoRoute(
          path: '/start', // 스플래시: 토큰 확인 중 / 확인 실패 시 재시도
          builder: (context, state) {
            final auth = context.watch<AuthViewModel>();
            return SplashScreen(
              message: auth.message,
              onRetry: auth.status == AuthStatus.retryRequired
                  ? auth.restoreSession
                  : null,
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
            create: (context) => SignUpViewModel(context.read<SignUpService>()),
            child: const SignUpScreen(),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainScreen(
              currentIndex: indexFromLocation(state.uri.path),
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
                      initialMovie: extra is TmdbMovieDto && extra.id == id
                          ? extra
                          : null,
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
                  // 7주차까지 쓰던 memberId 대신 토큰 기반 Service와 현재 세션 평점을 사용합니다.
                  builder: (context, state) =>
                      ChangeNotifierProvider<MyRatingsViewModel>(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      context.read<SessionRatingStore>(),
                      context.read<AuthViewModel>(),
                    )..load(),
                    child: const MyRatingsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'profile/edit', // 최종 경로: /my/profile/edit
                  parentNavigatorKey: rootNavigatorKey,
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
                              ? MovieLogButton(
                                  label: '다시 시도',
                                  onPressed: () =>
                                      auth.loadMember(force: true),
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
              ],
            ),
          ],
        ),
      ],
    );
  }

  static int indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}
