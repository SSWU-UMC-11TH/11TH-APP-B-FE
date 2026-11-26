import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../models/movie_detail_args.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/movie_detail_view_model.dart';
import 'movie_detail_screen.dart';

/// 영화 상세 화면의 시작점.
/// extra(목록에서 넘긴 영화)가 없으면 직접 접근·Deep Link로 보고 TMDB GET /movie/{id}로 다시 조회합니다.
class MovieDetailLoader extends StatefulWidget {
  const MovieDetailLoader({super.key, required this.movieId, this.initialArgs});

  final int movieId;
  final MovieDetailArgs? initialArgs;

  @override
  State<MovieDetailLoader> createState() => _MovieDetailLoaderState();
}

class _MovieDetailLoaderState extends State<MovieDetailLoader> {
  late final Future<TmdbMovieDto> _movieFuture;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialArgs?.movie;
    _movieFuture = initial != null
        ? Future.value(initial)
        : context.read<TmdbMovieService>().fetchMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TmdbMovieDto>(
      future: _movieFuture, // build마다 새 Future를 만들지 않습니다.
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text('영화를 불러오지 못했습니다.')));
        }
        return ChangeNotifierProvider<MovieDetailViewModel>(
          create: (context) => MovieDetailViewModel(
            context.read<RatingApiService>(),
            context.read<LearningMemberSession>().memberId,
            snapshot.data!,
          ),
          child: MovieDetailScreen(
            genreNames: widget.initialArgs?.genreNames ?? const [],
          ),
        );
      },
    );
  }
}
