import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/load_phase.dart';
import '../view_models/movie_search_view_model.dart';
import '../widgets/tmdb_poster_image.dart';
import 'tmdb_movie_detail_screen.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    context.read<MovieSearchViewModel>().search(_controller.text);
  }

  void _openDetail(TmdbMovieDto movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TmdbMovieDetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MovieSearchViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          '영화 검색',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: '영화 제목을 검색해 주세요.',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: '검색',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: switch (vm.phase) {
              LoadPhase.idle => const Center(child: Text('검색어를 입력해 주세요.')),
              LoadPhase.loading => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              LoadPhase.empty => const Center(child: Text('검색 결과가 없습니다.')),
              LoadPhase.error => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.errorMessage ?? '검색에 실패했습니다.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: vm.retry,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
              LoadPhase.ready => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vm.movies.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final movie = vm.movies[index];

                  return _SearchMovieCard(
                    movie: movie,
                    onTap: () => _openDetail(movie),
                  );
                },
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _SearchMovieCard extends StatelessWidget {
  const _SearchMovieCard({required this.movie, required this.onTap});

  final TmdbMovieDto movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightviolet),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TmdbPosterImage(
                  posterPath: movie.posterPath,
                  width: 76,
                  height: 110,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.releaseDate?.split('-').first ?? '개봉일 미정',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '평점 ${movie.voteAverage.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
