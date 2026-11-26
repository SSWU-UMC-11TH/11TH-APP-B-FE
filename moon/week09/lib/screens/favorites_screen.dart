import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../theme/app_colors.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/load_phase.dart';
import '../widgets/tmdb_poster_image.dart';
import 'tmdb_movie_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Map<int, Future<TmdbMovieDto>> _movieRequests = {};

  Future<TmdbMovieDto> _getMovie(int movieId) {
    return _movieRequests.putIfAbsent(
      movieId,
      () => context.read<TmdbMovieService>().fetchMovieDetail(movieId),
    );
  }

  Future<void> _refresh() async {
    _movieRequests.clear();
    await context.read<FavoritesViewModel>().loadFavorites();
  }

  Future<void> _openDetail(TmdbMovieDto movie) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TmdbMovieDetailScreen(movie: movie),
      ),
    );

    if (!mounted) return;
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavoritesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          '내 즐겨찾기',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: switch (vm.phase) {
        LoadPhase.idle ||
        LoadPhase.loading => const Center(child: CircularProgressIndicator()),
        LoadPhase.empty => _buildEmpty(),
        LoadPhase.error => _buildError(vm),
        LoadPhase.ready => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.favorites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final favorite = vm.favorites[index];

              return FutureBuilder<TmdbMovieDto>(
                future: _getMovie(favorite.movieId),
                builder: (context, snapshot) {
                  return _buildMovieCard(
                    movieId: favorite.movieId,
                    movie: snapshot.data,
                    loading: snapshot.connectionState != ConnectionState.done,
                    failed: snapshot.hasError,
                  );
                },
              );
            },
          ),
        ),
      },
    );
  }

  Widget _buildMovieCard({
    required int movieId,
    required TmdbMovieDto? movie,
    required bool loading,
    required bool failed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.lightviolet),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              height: 116,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: movie == null
                    ? Container(
                        color: AppColors.statBackground,
                        child: const Icon(
                          Icons.movie_outlined,
                          color: AppColors.primary,
                        ),
                      )
                    : TmdbPosterImage(
                        posterPath: movie.posterPath,
                        width: 84,
                        height: 116,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie?.title ?? '영화 ID: $movieId',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (loading)
                    const Text('영화 정보를 불러오는 중...')
                  else if (failed)
                    const Text('영화 정보를 불러오지 못했어요.')
                  else
                    const Text('즐겨찾기한 영화'),
                  const SizedBox(height: 10),
                  if (movie != null)
                    TextButton(
                      onPressed: () => _openDetail(movie),
                      child: const Text('영화 상세 보기'),
                    ),
                  if (failed)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _movieRequests.remove(movieId);
                        });
                      },
                      child: const Text('정보 다시 불러오기'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, size: 50, color: AppColors.primary),
          SizedBox(height: 20),
          Text(
            '아직 즐겨찾기한 영화가 없습니다.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Text('영화 상세에서 북마크를 눌러보세요.'),
        ],
      ),
    );
  }

  Widget _buildError(FavoritesViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('즐겨찾기를 불러오지 못했습니다.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: vm.retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
