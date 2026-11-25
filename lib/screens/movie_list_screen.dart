import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/movie_list_view_model.dart';
import '../widgets/genre_chip_list.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  // TMDB에 없는 장르 id. Empty 화면을 실제 API 응답으로 재현할 때만 쓴다.
  static const _emptyTestGenreId = 999999;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '영화',
          style: TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6750A4),
          ),
        ),
        actions: [
          // 테스트용: 없는 장르로 요청해서 Empty 상태 확인 (제출 전 삭제 가능)
          IconButton(
            tooltip: 'Empty 테스트',
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () => context.read<MovieListViewModel>().selectGenre(
              _emptyTestGenreId,
            ),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Consumer<MovieListViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              if (viewModel.genres.isNotEmpty)
                GenreChipList(
                  genres: viewModel.genres,
                  selectedGenreId: viewModel.selectedGenreId,
                  enabled: !viewModel.isLoading,
                  onGenreSelected: (genreId) =>
                      context.read<MovieListViewModel>().selectGenre(genreId),
                ),
              Expanded(
                child: switch (viewModel.status) {
                  MovieListLoadStatus.idle ||
                  MovieListLoadStatus.loading => const MovieListLoading(),
                  MovieListLoadStatus.error => MovieListError(
                    message: viewModel.message,
                    onRetry: () => context.read<MovieListViewModel>().retry(),
                  ),
                  MovieListLoadStatus.empty => const MovieListEmpty(),
                  MovieListLoadStatus.success => MovieGrid(
                    movies: viewModel.movies,
                    genreNamesOf: viewModel.genreNamesOf,
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
