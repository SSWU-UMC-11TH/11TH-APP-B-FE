import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/movie.dart';
import '../widgets/movie_rating.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final int? id = int.tryParse(widget.movieId);
    final movie = id != null ? findMovieById(id) : null;

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('영화 상세')),
        body: const Center(child: Text('해당 영화 정보를 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema Archive'),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영화 메인 포스터/배너
            Image.asset(
              movie.posterUrl,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 및 즐겨찾기 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isFavorite
                                    ? '즐겨찾기에 추가되었습니다.'
                                    : '즐겨찾기에서 삭제되었습니다.',
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 정보 (연도, 장르, 상영시간)
                  Text(
                    '${movie.year} · ${movie.genre} · ${movie.runtime}분',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // 읽기 전용 별점 (RatingBarIndicator 사용)
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.rating,
                        itemCount: 5,
                        itemSize: 20,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.purple),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${movie.rating} (${movie.ratingCount})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 태그 Chip 목록
                  Wrap(
                    spacing: 8,
                    children: movie.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey[200],
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // 줄거리
                  Text(
                    movie.description,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // 평점 남기기 버튼 (Dialog 연결)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final rating = await showDialog<double>(
                          context: context,
                          builder: (context) => const MovieRatingDialog(),
                        );

                        if (rating != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$rating점 평점이 남겨졌습니다!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.star_outline),
                      label: const Text('평점 남기기'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
