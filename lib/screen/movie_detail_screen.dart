import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../data/models/tmdb_movie_dto.dart'; 
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  final TmdbMovieDto movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;

  String get _year {
    final date = widget.movie.releaseDate;
    if (date == null || date.isEmpty) return '개봉일 미정';
    return date.split('-').first;
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie; 
    final score = movie.voteAverage / 2; 

    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_year, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            // 읽기 전용 별점 표시
            Row(
              children: [
                RatingBarIndicator(
                  rating: score,
                  itemCount: 5,
                  itemSize: 20,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                ),
                const SizedBox(width: 8),
                Text(
                  score.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              movie.overview.isNotEmpty ? movie.overview : '줄거리 정보가 없습니다.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                // 즐겨찾기 버튼 및 Snackbar
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 삭제되었습니다.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    label: Text(isFavorite ? '즐겨찾기 해제' : '즐겨찾기'),
                  ),
                ),
                const SizedBox(width: 12),
                // 별점 남기기 Dialog 버튼
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<RatingResult>(
                        context: context,
                        builder: (context) => RatingDialog(movieId: movie.id),
                      );
                      if (!mounted) return; // mounted 먼저 체크 후 return
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${movie.title}에 평점 ${result.rating}점이 등록되었습니다.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('평점 남기기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}