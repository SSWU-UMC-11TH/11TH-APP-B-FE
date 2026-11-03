import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class TmdbConfig {
  static const _tokenKey = 'TMDB_ACCESS_TOKEN';

  static String get accessToken => dotenv.env[_tokenKey] ?? '';

  static bool get hasAccessToken => accessToken.isNotEmpty;
}
