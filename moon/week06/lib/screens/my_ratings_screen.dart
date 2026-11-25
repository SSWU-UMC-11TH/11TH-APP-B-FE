import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyRatingsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '내가 등록한 평점',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, MyRatingsViewModel viewModel) {
    switch (viewModel.status) {
      case MyRatingsLoadStatus.idle:
      case MyRatingsLoadStatus.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('평점 목록을 불러오는 중입니다.'),
            ],
          ),
        );

      case MyRatingsLoadStatus.empty:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_border_rounded,
                size: 56,
                color: AppColors.primary,
              ),
              SizedBox(height: 12),
              Text('아직 등록된 평점이 없습니다.'),
            ],
          ),
        );

      case MyRatingsLoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 52,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  viewModel.errorMessage ?? '평점 목록을 불러오지 못했습니다.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadRatings(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        );

      case MyRatingsLoadStatus.success:
        return RefreshIndicator(
          onRefresh: () => viewModel.loadRatings(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.ratings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _RatingCard(item: viewModel.ratings[index]);
            },
          ),
        );
    }
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.item});

  final RatingWithMovie item;

  @override
  Widget build(BuildContext context) {
    final rating = item.rating;
    final movie = item.movie;

    final posterPath = movie?.posterPath;
    final posterUrl = posterPath != null && posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w185$posterPath'
        : null;

    final score = rating.score.clamp(0, 5).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 84,
              height: 120,
              child: posterUrl == null
                  ? const _PosterPlaceholder()
                  : Image.network(
                      posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _PosterPlaceholder(),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? '영화 정보 없음 (ID: ${rating.movieId})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (int i = 0; i < 5; i++)
                      Icon(
                        i < score
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      '${rating.score}점',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rating.comment?.isNotEmpty == true
                      ? rating.comment!
                      : '작성한 한줄평이 없습니다.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.fieldBackground,
      alignment: Alignment.center,
      child: const Icon(
        Icons.movie_outlined,
        size: 34,
        color: AppColors.primary,
      ),
    );
  }
}
