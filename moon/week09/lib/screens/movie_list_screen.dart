import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/movie_list_view_model.dart';
import '../widgets/movie_empty.dart';
import '../widgets/movie_loading.dart';
import '../widgets/tmdb_poster_image.dart';
import 'tmdb_movie_detail_screen.dart';

import 'package:go_router/go_router.dart';

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
                  tooltip: '영화 검색',
                  onPressed: () => context.push('/movies/search'),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<MovieListViewModel>(
              builder: (context, viewModel, _) {
                return _GenreChips(
                  genres: viewModel.genres,
                  selectedGenreId: viewModel.selectedGenreId,
                  isLoading: viewModel.isLoading,
                  onGenreSelected: (genreId) {
                    context.read<MovieListViewModel>().selectGenre(genreId);
                  },
                );
              },
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Consumer<MovieListViewModel>(
                builder: (context, viewModel, _) {
                  switch (viewModel.status) {
                    case MovieListLoadStatus.idle:
                    case MovieListLoadStatus.loading:
                      return const MovieLoading();

                    case MovieListLoadStatus.empty:
                      return const MovieEmpty();

                    case MovieListLoadStatus.error:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              viewModel.message ?? '영화를 불러오지 못했어요.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: viewModel.retry,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      );

                    case MovieListLoadStatus.success:
                      return _MovieGrid(
                        movies: viewModel.movies,
                        genres: viewModel.genres,
                        viewModel: viewModel,
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
    final genreItems = <TmdbGenreDto?>[null, ...genres];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: genreItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genreItems[index];
          final genreId = genre?.id;
          final isSelected = selectedGenreId == genreId;

          return ChoiceChip(
            label: Text(genre?.name ?? '전체'),
            selected: isSelected,
            showCheckmark: false,
            onSelected: isLoading ? null : (_) => onGenreSelected(genreId),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
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

class _MovieGrid extends StatelessWidget {
  const _MovieGrid({
    required this.movies,
    required this.genres,
    required this.viewModel,
  });

  final List<TmdbMovieDto> movies;
  final List<TmdbGenreDto> genres;
  final MovieListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final movie = movies[index];

              return _MovieGridItem(
                movie: movie,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          TmdbMovieDetailScreen(movie: movie, genres: genres),
                    ),
                  );
                },
              );
            }, childCount: movies.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 18,
              childAspectRatio: 0.58,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _MoviePageFooter(viewModel: viewModel)),
      ],
    );
  }
}

class _MoviePageFooter extends StatelessWidget {
  const _MoviePageFooter({required this.viewModel});

  final MovieListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                '영화를 더 불러오는 중...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              viewModel.loadMoreError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: viewModel.loadMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('다음 페이지 다시 시도'),
              ),
            ),
          ],
        ),
      );
    }

    if (!viewModel.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            '모든 영화를 확인했습니다.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: viewModel.loadMore,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            '더 보기',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _MovieGridItem extends StatelessWidget {
  const _MovieGridItem({required this.movie, required this.onTap});

  final TmdbMovieDto movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final releaseYear = movie.releaseDate == null || movie.releaseDate!.isEmpty
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
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.white),
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
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
