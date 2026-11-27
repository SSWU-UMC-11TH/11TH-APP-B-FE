import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../view_models/movie_home_view_model.dart';
import '../widgets/tmdb_poster_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featuredMovie = mockMovies.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MovieLog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 타이틀
            const Text(
              '오늘은 어떤\n영화를 볼까요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),

            // 2. 추천 신작 대표 카드 (mock 그대로)
            GestureDetector(
              onTap: () => context.push('/movies/${featuredMovie.id}'),
              child: Container(
                width: double.infinity,
                height: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/movie_1.png'),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6750A4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '추천 신작',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      featuredMovie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${featuredMovie.genre} · ${featuredMovie.duration}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/movies/${featuredMovie.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6750A4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('상세보기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 3. 인기 영화 가로 스크롤 섹션 (TMDB)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '인기 영화',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => context.go('/movies'),
                  child: const Row(
                    children: [
                      Text(
                        '전체보기',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 225,
              child: Consumer<MovieHomeViewModel>(
                builder: (context, vm, child) {
                  return switch (vm.status) {
                    MovieHomeLoadStatus.idle ||
                    MovieHomeLoadStatus.loading =>
                      const Center(child: CircularProgressIndicator()),
                    MovieHomeLoadStatus.error => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(vm.message ?? '오류가 발생했어요.'),
                            TextButton(
                              onPressed: () => context
                                  .read<MovieHomeViewModel>()
                                  .loadPopular(),
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      ),
                    MovieHomeLoadStatus.empty =>
                      const Center(child: Text('인기 영화가 없어요.')),
                    MovieHomeLoadStatus.success => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: vm.popularMovies.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final movie = vm.popularMovies[index];
                          return GestureDetector(
                            onTap: () => context.push('/movies/${movie.id}'),
                            child: SizedBox(
                              width: 110,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: TmdbPosterImage(
                                      posterPath: movie.posterPath,
                                      width: 110,
                                      height: 165,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    movie.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        movie.voteAverage.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}