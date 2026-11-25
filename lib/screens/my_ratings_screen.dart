import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/tmdb_poster_image.dart';

/// 마이페이지 → 내가 등록한 평점.
/// 6주차는 로그인 기능이 없어 학습용 memberId 1의 샘플 평점을 조회한다.
class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // bottomNavigationBar를 전달하지 않는다. (root Navigator 위에 열림)
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: const Text('내가 등록한 평점', style: AppTextStyles.appBarTitle),
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          return switch (viewModel.status) {
            MyRatingsLoadStatus.idle || MyRatingsLoadStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            MyRatingsLoadStatus.empty => const Center(
              child: Text('등록한 평점이 없어요.', style: AppTextStyles.bodyMedium),
            ),
            MyRatingsLoadStatus.error => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewModel.message ?? '평점을 불러오지 못했습니다.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // 고정 값 너비 예시: 화면 크기와 관계없이 항상 120
                  MovieLogButton(
                    label: '다시 시도',
                    width: 120,
                    onPressed: () => context.read<MyRatingsViewModel>().load(),
                  ),
                ],
              ),
            ),
            MyRatingsLoadStatus.success => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '학습용 샘플 회원(memberId ${viewModel.memberId})의 평점입니다.',
                  style: AppTextStyles.bodySmall,
                ),
                // 일부 영화 정보를 못 가져왔을 때 안내
                if (viewModel.message != null) ...[
                  const SizedBox(height: 4),
                  Text(viewModel.message!, style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 12),
                for (final entry in viewModel.ratings) ...[
                  _RatingCard(entry: entry),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          };
        },
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie; // null이면 TMDB에서 못 찾은 영화
    final created = rating.createdAt.toLocal();
    final date =
        '${created.year}.${created.month.toString().padLeft(2, '0')}.'
        '${created.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // posterPath가 null이면 TmdbPosterImage가 placeholder를 그린다.
            child: TmdbPosterImage(
              posterPath: movie?.posterPath,
              width: 64,
              height: 96,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? '영화 정보 없음',
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (movie == null)
                  Text(
                    'movieId ${rating.movieId}',
                    style: AppTextStyles.bodySmall,
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: rating.score.toDouble(),
                      itemCount: 5,
                      itemSize: 18,
                      itemBuilder: (_, _) =>
                          const Icon(Icons.star, color: AppColors.violet),
                    ),
                    const SizedBox(width: 6),
                    Text('${rating.score}점', style: AppTextStyles.bodyMedium),
                  ],
                ),
                // comment가 null이면 표시하지 않는다.
                if (rating.comment != null) ...[
                  const SizedBox(height: 6),
                  Text(rating.comment!, style: AppTextStyles.bodyMedium),
                ],
                const SizedBox(height: 6),
                Text(date, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
