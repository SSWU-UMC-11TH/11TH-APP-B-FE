import 'package:flutter/material.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '내가 등록한 평점',
          style: TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w500,
            color: AppColors.violet,
          ),
        ),
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
            MyRatingsLoadStatus.success => ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              itemCount: viewModel.ratings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  _RatingCard(entry: viewModel.ratings[index]),
            ),
          };
        },
      ),
    );
  }
}

const _textMain = Color(0xFF1D1B20);
const _textSub = Color(0xFF494551);
const _cardBorder = Color(0xFFCBC4D2);
const _posterPlaceholder = Color(0xFFD9D2E0);

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie; // null이면 TMDB에서 못 찾은 영화
    final posterPath = movie?.posterPath;
    final created = rating.createdAt.toLocal();
    final date =
        '${created.year}.${created.month.toString().padLeft(2, '0')}.'
        '${created.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // 영화나 포스터가 없으면 연보라 placeholder
            child: posterPath == null
                ? Container(width: 82, height: 124, color: _posterPlaceholder)
                : TmdbPosterImage(
                    posterPath: posterPath,
                    width: 82,
                    height: 124,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // TMDB에서 못 찾으면 movieId로 대신 표시
                    movie?.title ?? '영화 #${rating.movieId}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 24 / 17,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '별점 ${rating.score} / 5',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.violet,
                    ),
                  ),
                  if (movie == null) ...[
                    const SizedBox(height: 8),
                    const Text('포스터 정보 없음', style: _subStyle),
                  ],
                  // comment가 null이면 표시하지 않는다.
                  if (rating.comment != null) ...[
                    const SizedBox(height: 8),
                    Text(rating.comment!, style: _subStyle),
                  ],
                  const SizedBox(height: 8),
                  Text(date, style: _subStyle), // 워크북: 등록일 표시
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _subStyle = TextStyle(fontSize: 13, height: 18 / 13, color: _textSub);
