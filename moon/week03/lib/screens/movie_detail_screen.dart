import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  final Movie movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;

  Movie get movie => widget.movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // 상단바
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),

      // 하단 고정 버튼
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              // =========================
              // 즐겨찾기
              // =========================
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? '${movie.title}을(를) 즐겨찾기에 추가했습니다.'
                                : '${movie.title}을(를) 즐겨찾기에서 삭제했습니다.',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: Icon(
                      isFavorite
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 18,
                    ),
                    label: Text(
                      isFavorite ? '즐겨찾기됨' : '즐겨찾기',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // =========================
              // 평점 남기기
              // =========================
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final rating = await showDialog<double>(
                        context: context,
                        builder: (context) {
                          return const RatingDialog();
                        },
                      );

                      if (rating != null && context.mounted) {
                        debugPrint(
                          '${movie.title} 평점: ${rating.toStringAsFixed(1)}',
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${rating.toStringAsFixed(1)}점을 남겼습니다.',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(
                      Icons.rate_review_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      '평점 남기기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // =========================
      // 스크롤 본문
      // =========================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영화 이미지
            AspectRatio(
              aspectRatio: 1.25,
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  movie.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 영화 제목
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 연도 / 장르 / 상영시간
                  Text(
                    '${movie.year} · '
                    '${movie.genres.join('/')} · '
                    '${movie.duration}분',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 평균 별점
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: AppColors.primary,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                        unratedColor: AppColors.fieldBorder,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '(${_formatNumber(movie.ratingCount)})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 장르 Chip
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...movie.genres.map(
                        (genre) => _buildChip(genre),
                      ),

                      if (movie.id == 1) _buildChip('감동적인'),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.fieldBorder,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    '시놉시스',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    movie.synopsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.bodytext,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chip 공통 디자인
  Widget _buildChip(String text) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.statBackground,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  // 1245 -> 1,245
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}