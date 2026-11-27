import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../data/models/create_rating_request.dart';
import '../models/movie_detail_args.dart';
import '../widgets/movie_rating.dart';
import '../widgets/tmdb_poster_image.dart';

const _bg = Color(0xFFFAF9F5);
const _violet = Color(0xFF6750A4);
const _textMain = Color(0xFF1D1B20);
const _textSub = Color(0xFF494551);
const _chipBg = Color(0xFFE8DEF9);

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId, this.args});

  /// 경로 /movies/:movieId 의 값 (TMDB 영화 id)
  final String movieId;

  /// 목록·홈에서 넘겨준 영화 데이터. 앱 재시작 등으로 없을 수 있다.
  final MovieDetailArgs? args;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _myRating; // 내가 남긴 평점 (없으면 null)

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가했어요' : '즐겨찾기를 해제했어요'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showRatingDialog(int movieId) async {
    final request = await showDialog<CreateRatingRequest>(
      context: context,
      builder: (_) => MovieRatingDialog(
        movieId: movieId, // TMDB id를 평점 Dialog로 전달
        initialRating: _myRating ?? 3.0,
      ),
    );
    if (!mounted || request == null) return;

    // 자체 API 연동 전까지는 로그로 movieId 전달을 확인한다.
    debugPrint('[평점] CreateRatingRequest ${request.toJson()}');

    setState(() => _myRating = request.score);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${request.score}점을 남겼어요')));
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final movieId = int.tryParse(widget.movieId);

    if (args == null || movieId == null || args.movie.id != movieId) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(backgroundColor: _bg, title: const Text('영화 상세')),
        body: const Center(
          child: Text(
            '영화 정보를 찾을 수 없어요.\n목록에서 다시 선택해 주세요.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final movie = args.movie;
    final year = movie.releaseDate?.split('-').first; // 없으면 표시 안 함
    final score = movie.voteAverage / 2; // TMDB 10점 → 5점 만점

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '영화 상세',
          style: TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w500,
            color: _violet,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TmdbPosterImage(
              posterPath: movie.posterPath,
              width: double.infinity,
              height: 350,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  if (year != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$year년 개봉',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: _textSub,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: score,
                        itemCount: 5,
                        itemSize: 20,
                        itemBuilder: (_, _) =>
                            const Icon(Icons.star, color: _violet),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${score.toStringAsFixed(1)} · TMDB ${movie.voteAverage.toStringAsFixed(1)}/10',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textSub,
                        ),
                      ),
                    ],
                  ),
                  if (_myRating != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '내 평점 ★ $_myRating',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _violet,
                      ),
                    ),
                  ],
                  if (args.genreNames.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final genre in args.genreNames)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _chipBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4F378A),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFCBC4D2)),
                  const SizedBox(height: 16),
                  const Text(
                    '시놉시스',
                    style: TextStyle(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (movie.overview.isEmpty)
                    // overview가 없으면 가운데에 안내 문구
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          '줄거리 정보가 없어요.',
                          style: TextStyle(fontSize: 16, color: _textSub),
                        ),
                      ),
                    )
                  else
                    Text(
                      movie.overview,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: _textSub,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: _violet,
                    ),
                    label: const Text('즐겨찾기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _violet,
                      side: const BorderSide(color: _violet),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _showRatingDialog(movie.id),
                    icon: Icon(
                      _myRating == null ? Icons.star_border : Icons.refresh,
                    ),
                    label: Text(_myRating == null ? '평점 남기기' : '다시 선택하기'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _violet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
