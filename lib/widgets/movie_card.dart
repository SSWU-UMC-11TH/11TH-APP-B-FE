import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../models/movie_detail_args.dart';
import 'tmdb_poster_image.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, this.genreNames = const []});

  final TmdbMovieDto movie;
  final List<String> genreNames;

  @override
  Widget build(BuildContext context) {
    // release_date가 없으면 연도는 빼고 보여 준다.
    final year = movie.releaseDate?.split('-').first;
    final subtitle = [
      ?year,
      if (genreNames.isNotEmpty) genreNames.first,
    ].join(' · ');

    return GestureDetector(
      onTap: () => context.push(
        '/movies/${movie.id}', // 배열 index가 아니라 TMDB id
        extra: MovieDetailArgs(movie: movie, genreNames: genreNames),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 포스터 + 평점 뱃지
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: TmdbPosterImage(
                    posterPath: movie.posterPath,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC322F35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '★ ${(movie.voteAverage / 2).toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Color(0xFFF5EFF7),
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D1B20),
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w400,
              color: Color(0xCC1D1B20),
            ),
          ),
        ],
      ),
    );
  }
}
