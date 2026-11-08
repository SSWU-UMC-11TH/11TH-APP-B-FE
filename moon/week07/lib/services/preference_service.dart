import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _genreKey = 'selected_genre';


  Future<void> saveGenre(String genre) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _genreKey,
      genre,
    );
  }


  Future<String?> loadGenre() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      _genreKey,
    );
  }
}