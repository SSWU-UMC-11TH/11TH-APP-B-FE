import 'package:flutter/material.dart';
import 'package:flutter_application_1/movie_log_app.dart';

class Movie {
  const Movie({required this.id, required this.title});

  final int id;
  final String title;
}

String getDisplayName(String? nickname) {
  return nickname?.trim().isNotEmpty == true ? nickname! : '무비러버';
}

void main() {
  final movies = <Movie>[
    const Movie(id: 1, title: '파묘'),
    const Movie(id: 2, title: '인사이드 아웃 2'),
    const Movie(id: 3, title: '범죄도시 4'),
  ];

  debugPrint('--- 영화 목록 ---');
  for (final movie in movies) {
    debugPrint(movie.title);
  }

  String? userNickname;
  debugPrint('사용자 닉네임: ${getDisplayName(userNickname)}');

  runApp(const MovieLogApp());
}
