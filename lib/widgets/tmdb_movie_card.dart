import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/tmdb_movie_dto.dart';
import 'tmdb_poster_image.dart';

class TmdbMovieCard extends StatelessWidget {
  const TmdbMovieCard({super.key, required this.movie});

  final TmdbMovieDto movie;

  String? get _year {
    final date = movie.releaseDate;
    if (date == null || date.length < 4) return null; // 없으면 연도 표시 안 함
    return date.substring(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final year = _year;

    return GestureDetector(
      // TMDB id를 그대로 전달 (이후 평점 movieId로 사용)
      onTap: () => context.push('/movies/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      TmdbPosterImage(
                        posterPath: movie.posterPath,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (year != null)
            Text(
              year,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
        ],
      ),
    );
  }
}