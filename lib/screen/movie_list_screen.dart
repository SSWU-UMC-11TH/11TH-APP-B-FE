import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/movie_list_view_model.dart';
import '../widgets/status/movie_empty_widget.dart';
import '../widgets/status/movie_error_widget.dart';
import '../widgets/status/movie_loading_widget.dart';
import '../widgets/tmdb_movie_card.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영화')),
      body: Column(
        children: [
          // 장르 Chip 목록 (Genre API의 id/name 사용)
          SizedBox(
            height: 50,
            child: Consumer<MovieListViewModel>(
              builder: (context, vm, child) {
                final isLoading = vm.isLoading;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    // "전체" = genreId null
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('전체'),
                        selected: vm.selectedGenreId == null,
                        // 요청 중에는 장르 변경 불가
                        onSelected: isLoading
                            ? null
                            : (_) => context
                                .read<MovieListViewModel>()
                                .selectGenre(null),
                      ),
                    ),
                    for (final genre in vm.genres)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(genre.name),
                          selected: vm.selectedGenreId == genre.id,
                          onSelected: isLoading
                              ? null
                              : (_) => context
                                  .read<MovieListViewModel>()
                                  .selectGenre(genre.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Loading / Error / Empty / Success
          Expanded(
            child: Consumer<MovieListViewModel>(
              builder: (context, vm, child) {
                return switch (vm.status) {
                  MovieListLoadStatus.idle ||
                  MovieListLoadStatus.loading =>
                    const MovieLoadingWidget(),
                  MovieListLoadStatus.error => MovieErrorWidget(
                      onRetry: () =>
                          context.read<MovieListViewModel>().loadInitial(),
                    ),
                  MovieListLoadStatus.empty => const MovieEmptyWidget(),
                  MovieListLoadStatus.success => GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: vm.movies.length,
                      itemBuilder: (context, index) {
                        return TmdbMovieCard(movie: vm.movies[index]);
                      },
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}