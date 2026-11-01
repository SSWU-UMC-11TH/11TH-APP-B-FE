import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/network/tmdb_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/services/tmdb_movie_service.dart';

import 'app/movie_log_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env'); 

  runApp(const MovieLogApp());
}