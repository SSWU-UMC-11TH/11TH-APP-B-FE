import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/movie.dart';
import '../widgets/movie_rating.dart';

const _bg = Color(0xFFFAF9F5);
const _violet = Color(0xFF6750A4);
const _textMain = Color(0xFF1D1B20);
const _textSub = Color(0xFF494551);
const _chipBg = Color(0xFFE8DEF9);

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _myRating; // 내가 남긴 평점 (없으면 null)

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가했어요' : '즐겨찾기를 해제했어요'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showRatingDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => MovieRatingDialog(initialRating: _myRating ?? 3.0),
    );
    if (!mounted || result == null) return;
    setState(() => _myRating = result);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$result점을 남겼어요')));
  }

  @override
  Widget build(BuildContext context) {
    final int? id = int.tryParse(widget.movieId);
    final movie = id != null ? findMovieById(id) : null;

    if (movie == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(backgroundColor: _bg, title: const Text('영화 상세')),
        body: const Center(child: Text('해당 영화 정보를 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '영화 상세',
          style: TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w500,
            color: _violet,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              movie.posterUrl,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 350,
                color: const Color(0xFFE6E0E9),
                child: const Center(child: Icon(Icons.movie, size: 64)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.year} · ${movie.runtime}분 · ${movie.genre}',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: _textSub,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.rating,
                        itemCount: 5,
                        itemSize: 20,
                        itemBuilder: (_, _) =>
                            const Icon(Icons.star, color: _violet),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${movie.rating} (${movie.ratingCount})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textSub,
                        ),
                      ),
                    ],
                  ),
                  if (_myRating != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '내 평점 ★ $_myRating',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _violet,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in movie.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _chipBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4F378A),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFCBC4D2)),
                  const SizedBox(height: 16),
                  const Text(
                    '시놉시스',
                    style: TextStyle(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: _textSub,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: _violet,
                    ),
                    label: const Text('즐겨찾기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _violet,
                      side: const BorderSide(color: _violet),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _showRatingDialog,
                    icon: Icon(
                      _myRating == null ? Icons.star_border : Icons.refresh,
                    ),
                    label: Text(_myRating == null ? '평점 남기기' : '다시 선택하기'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _violet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
