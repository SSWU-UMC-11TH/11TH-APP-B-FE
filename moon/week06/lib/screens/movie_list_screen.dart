
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/movie_list_view_model.dart';
import '../widgets/tmdb_poster_image.dart';
import '../widgets/movie_loading.dart';
import '../widgets/movie_empty.dart';
import 'tmdb_movie_detail_screen.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '영화',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // TMDB Genre API 기반 장르 목록
            Consumer<MovieListViewModel>(
              builder: (context, viewModel, child) {
                return _GenreChips(
                  genres: viewModel.genres,
                  selectedGenreId: viewModel.selectedGenreId,
                  isLoading: viewModel.isLoading,
                  onGenreSelected: (genreId) {
                    context
                        .read<MovieListViewModel>()
                        .selectGenre(genreId);
                  },
                );
              },
            ),

            const SizedBox(height: 18),

            // Loading / Empty / Error / Success
            Expanded(
              child: Consumer<MovieListViewModel>(
                builder: (context, viewModel, child) {
                  switch (viewModel.status) {
                    case MovieListLoadStatus.idle:
                    case MovieListLoadStatus.loading:
                      return const MovieLoading();

                    case MovieListLoadStatus.empty:
                      return const MovieEmpty();

                    case MovieListLoadStatus.error:
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              viewModel.message ??
                                  '영화를 불러오지 못했어요.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<MovieListViewModel>()
                                    .retry();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      );

                    case MovieListLoadStatus.success:
                      return _MovieGrid(
                        movies: viewModel.movies,
                        genres: viewModel.genres,
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TMDB Genre API 기반 장르 Chip
class _GenreChips extends StatelessWidget {
  const _GenreChips({
    required this.genres,
    required this.selectedGenreId,
    required this.isLoading,
    required this.onGenreSelected,
  });

  final List<TmdbGenreDto> genres;
  final int? selectedGenreId;
  final bool isLoading;
  final ValueChanged<int?> onGenreSelected;

  @override
  Widget build(BuildContext context) {
    final genreItems = <TmdbGenreDto?>[
      null, // 전체
      ...genres,
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: genreItems.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genreItems[index];
          final genreId = genre?.id;
          final isSelected = selectedGenreId == genreId;

          return ChoiceChip(
            label: Text(genre?.name ?? '전체'),
            selected: isSelected,
            showCheckmark: false,
            onSelected: isLoading
                ? null
                : (_) => onGenreSelected(genreId),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.chipBackground,
            disabledColor: AppColors.chipBackground,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}

// 영화 2열 Grid
class _MovieGrid extends StatelessWidget {
  const _MovieGrid({
    required this.movies,
    required this.genres,
  });

  final List<TmdbMovieDto> movies;
  final List<TmdbGenreDto> genres;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: movies.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 18,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];

        return _MovieGridItem(
          movie: movie,
          onTap: () {
            debugPrint(
              '[영화 상세 이동] TMDB movieId: ${movie.id}',
            );

            // 실제 TMDB 영화 DTO와 장르 목록 전달
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TmdbMovieDetailScreen(
                  movie: movie,
                  genres: genres,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 기존 4주차 카드 디자인 유지
class _MovieGridItem extends StatelessWidget {
  const _MovieGridItem({
    required this.movie,
    required this.onTap,
  });

  final TmdbMovieDto movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final releaseYear = movie.releaseDate == null ||
            movie.releaseDate!.isEmpty
        ? ''
        : movie.releaseDate!.split('-').first;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TmdbPosterImage(
                    posterPath: movie.posterPath,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: 0.7,
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            [
              if (releaseYear.isNotEmpty) releaseYear,
              '평점 ${movie.voteAverage.toStringAsFixed(1)}',
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
