import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/network/tmdb_client.dart';
import 'core/network/movie_log_client.dart';

import 'data/services/tmdb_movie_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/rating_api_service.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

import 'view_models/learning_member_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TMDB 환경변수 로드
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final movieLogClient = createMovieLogClient();

    return MultiProvider(
      providers: [
        // 학습용 회원 ID 관리
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),

        // TMDB 영화 데이터 조회
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),

        // 닉네임·이메일 중복 확인 및 회원가입
        Provider<SignUpService>(create: (_) => SignUpService(movieLogClient)),

        // 영화 평점 API
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
      ],

      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
