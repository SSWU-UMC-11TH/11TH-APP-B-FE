import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../data/models/rating_request.dart';
import '../data/services/rating_api_service.dart';
import '../view_models/learning_member_session.dart';
import '../theme/app_colors.dart';
import '../widgets/tmdb_poster_image.dart';
import '../widgets/rating_dialog.dart';

class TmdbMovieDetailScreen extends StatefulWidget {
  const TmdbMovieDetailScreen({
    super.key,
    required this.movie,
    this.genres = const [],
  });

  final TmdbMovieDto movie;
  final List<TmdbGenreDto> genres;

  @override
  State<TmdbMovieDetailScreen> createState() => _TmdbMovieDetailScreenState();
}

class _TmdbMovieDetailScreenState extends State<TmdbMovieDetailScreen> {
  bool isFavorite = false;
  bool _isRatingDialogOpen = false;

  TmdbMovieDto get movie => widget.movie;

  Future<void> _openRatingDialog() async {
    if (_isRatingDialogOpen) return;

    final memberId = context.read<LearningMemberSession>().memberId;

    if (memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('평점을 등록하려면 먼저 회원가입이 필요합니다.')),
      );
      return;
    }

    final ratingService = context.read<RatingApiService>();
    final movieId = movie.id;

    setState(() {
      _isRatingDialogOpen = true;
    });

    try {
      final rating = await showDialog<double>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return RatingDialog(
            movieId: movieId,
            onSubmit: (score, comment) async {
              await ratingService.createRating(
                memberId: memberId,
                request: CreateRatingRequest(
                  movieId: movieId,
                  score: score,
                  comment: comment,
                ),
              );
            },
          );
        },
      );

      if (!mounted || rating == null) return;

      debugPrint(
        '[평점 등록 성공] memberId=$memberId, '
        'movieId=$movieId, score=${rating.toInt()}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${rating.toInt()}점을 등록했습니다.'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRatingDialogOpen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final releaseDate = movie.releaseDate;
    final year = releaseDate != null && releaseDate.isNotEmpty
        ? releaseDate.split('-').first
        : '개봉일 미정';

    final genreNames = widget.genres
        .where((genre) => movie.genreIds.contains(genre.id))
        .map((genre) => genre.name)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });

                      debugPrint(
                        '[즐겨찾기] TMDB movieId=${movie.id}, '
                        'selected=$isFavorite',
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? '${movie.title}을(를) 즐겨찾기에 추가했습니다.'
                                : '${movie.title}을(를) 즐겨찾기에서 삭제했습니다.',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                    ),
                    label: Text(
                      isFavorite ? '즐겨찾기됨' : '즐겨찾기',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isRatingDialogOpen ? null : _openRatingDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text(
                      '평점 남기기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: TmdbPosterImage(
                posterPath: movie.backdropPath ?? movie.posterPath,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [year, ...genreNames].join(' · '),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: (movie.voteAverage / 2)
                            .clamp(0.0, 5.0)
                            .toDouble(),
                        itemBuilder: (_, _) =>
                            const Icon(Icons.star, color: AppColors.primary),
                        itemCount: 5,
                        itemSize: 20,
                        unratedColor: AppColors.fieldBorder,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '/ 10',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (genreNames.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: genreNames.map((name) {
                        return Chip(
                          label: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          backgroundColor: AppColors.statBackground,
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 28),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.fieldBorder,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '시놉시스',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movie.overview.isEmpty ? '줄거리 정보가 없어요.' : movie.overview,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.bodytext,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
