import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/movie_log_client.dart';
import '../core/network/tmdb_client.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../view_models/learning_member_session.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 워크북 백엔드(/v6)를 부르는 두 Service가 Dio 하나를 같이 쓴다.
    final movieLogClient = createMovieLogClient();

    return MultiProvider(
      providers: [
        // 여러 화면이 같이 쓰는 stateless Service는 앱 최상단에 하나만 둔다.
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        // 회원가입 결과의 memberId를 영화 상세·마이페이지가 같이 읽습니다.
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        Provider<SignUpService>(create: (_) => SignUpService(movieLogClient)),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
      ],
      child: MaterialApp.router(
        title: 'MovieLog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
