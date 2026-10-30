import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _genreKey = 'selected_genre';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<void> saveGenre(String genre) async {
    await _prefs.setString(_genreKey, genre);
  }

  Future<String?> loadGenre() async {
    return await _prefs.getString(_genreKey);
  }
}
