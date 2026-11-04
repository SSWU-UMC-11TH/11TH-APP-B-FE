
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/movie_home_view_model.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../widgets/tmdb_poster_image.dart';
import 'tmdb_movie_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16, 12, 16, 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기존 MovieLog 헤더 유지
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MovieLog',
                    style: TextStyle(
                      fontSize: 18,
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

              const SizedBox(height: 14),

              const Text(
                '오늘은 어떤\n영화를 볼까요?',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Consumer<MovieHomeViewModel>(
                builder: (context, viewModel, child) {
                  switch (viewModel.status) {
                    case MovieHomeLoadStatus.idle:
                    case MovieHomeLoadStatus.loading:
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child:
                              CircularProgressIndicator(),
                        ),
                      );

                    case MovieHomeLoadStatus.error:
                      return Center(
                        child: Column(
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
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<MovieHomeViewModel>()
                                    .loadPopular();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      );

                    case MovieHomeLoadStatus.empty:
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            '표시할 영화가 없어요.',
                          ),
                        ),
                      );

                    case MovieHomeLoadStatus.success:
                      final movies =
                          viewModel.popularMovies;

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _FeaturedMovie(
                            movie: movies.first,
                          ),
                          const SizedBox(height: 18),
                          _PopularMovies(
                            movies: movies,
                          ),
                        ],
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 상단 추천 영화 카드
class _FeaturedMovie extends StatelessWidget {
  const _FeaturedMovie({
    required this.movie,
  });

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: double.infinity,
        height: 390,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TmdbPosterImage(
              posterPath: movie.posterPath,
              width: double.infinity,
              height: 390,
            ),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),

            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '추천 신작',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    movie.releaseDate?.isNotEmpty ==
                            true
                        ? movie.releaseDate!
                            .split('-')
                            .first
                        : '개봉 정보 없음',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint(
                          '[홈 추천 영화 상세 이동] '
                          'TMDB movieId: ${movie.id}',
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                TmdbMovieDetailScreen(
                              movie: movie,
                            ),
                          ),
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text('상세보기'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 하단 인기 영화 가로 목록
class _PopularMovies extends StatelessWidget {
  const _PopularMovies({
    required this.movies,
  });

  final List<TmdbMovieDto> movies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '인기 영화',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.go('/movies'),
              child: const Text('전체보기 >'),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];

              return GestureDetector(
                onTap: () {
                  debugPrint(
                    '[홈 인기 영화 상세 이동] '
                    'TMDB movieId: ${movie.id}',
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          TmdbMovieDetailScreen(
                        movie: movie,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: 135,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10),
                        child: TmdbPosterImage(
                          posterPath:
                              movie.posterPath,
                          width: 135,
                          height: 180,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
