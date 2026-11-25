import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/network/tmdb_client.dart';
import 'core/network/movie_log_client.dart';

import 'data/services/tmdb_movie_service.dart';
import 'data/services/member_check_service.dart';
import 'data/services/rating_api_service.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

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
      Provider<TmdbMovieService>(
        create: (_) => TmdbMovieService(createTmdbClient()),
      ),
      Provider<MemberCheckService>(
        create: (_) => MemberCheckService(movieLogClient),
      ),
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