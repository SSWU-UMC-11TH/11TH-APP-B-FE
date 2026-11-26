import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../data/services/rating_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movie_rating.dart';
import '../widgets/movielog_button.dart';
import '../widgets/tmdb_poster_image.dart';

// Figma W7-01 평점 카드 · W7-04 삭제 확인 Dialog 기준 값
const _cardBorder = Color(0xFFD9D2E3);
const _posterPlaceholder = Color(0xFFD9D2E3);
const _textMain = Color(0xFF1D1B20);
const _textSub = Color(0xFF49454F);
const _editBg = Color(0xFFEEE9F8);
const _deleteBg = Color(0xFFFDECEC);
const _deleteText = Color(0xFFB3261E);

/// 마이페이지 → 내가 등록한 평점.
/// 회원가입 결과의 memberId(LearningMemberSession)로 조회하고, 카드별로 수정·삭제한다.
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
        leading: const BackButton(color: _textMain),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // 저장 성공 뒤 GET만 실패했다면 그 사실을 따로 알려줍니다.
                      viewModel.refreshWarning ??
                          viewModel.message ??
                          '평점을 불러오지 못했습니다.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // 고정 값 너비 예시: 화면 크기와 관계없이 항상 120
                    MovieLogButton(
                      label: '다시 시도',
                      width: 120,
                      // 조회(GET)만 다시 시도합니다. 저장 요청은 다시 보내지 않습니다.
                      onPressed: () =>
                          context.read<MyRatingsViewModel>().load(),
                    ),
                  ],
                ),
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

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie; // null이면 TMDB에서 못 찾은 영화
    // 평점 응답에는 제목·포스터가 없으므로 movieId로 찾은 TMDB 영화를 씁니다.
    final description = rating.comment ?? (movie == null ? '포스터 정보 없음' : null);

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
            child: movie == null
                ? Container(width: 82, height: 124, color: _posterPlaceholder)
                : TmdbPosterImage(
                    posterPath: movie.posterPath,
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
                      height: 20 / 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.violet,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 18 / 13,
                        color: _textSub,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                _SmallButton(
                  label: '수정',
                  background: _editBg,
                  foreground: AppColors.violet,
                  onPressed: () => onEditPressed(context, rating),
                ),
                const SizedBox(height: 8),
                _SmallButton(
                  label: '삭제',
                  background: _deleteBg,
                  foreground: _deleteText,
                  onPressed: () => onDeletePressed(context, rating),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 34,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

/// 수정: 등록과 같은 RatingDialog를 기존 별점·코멘트로 채워서 엽니다.
Future<void> onEditPressed(BuildContext context, RatingDto rating) async {
  final viewModel = context.read<MyRatingsViewModel>();
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
    builder: (_) => RatingDialog(
      initialScore: rating.score,
      initialComment: rating.comment, // null이면 TextField가 빈 칸으로 시작합니다.
      onSubmit: (score, comment) => viewModel.updateRating(
        ratingId: rating.ratingId,
        score: score,
        comment: comment,
      ),
    ),
  );

  // 취소·실패면 saved가 true가 아니므로 별도 처리 없이 끝납니다.
  // 성공 시 목록 재조회는 updateRating 안에서 이미 했습니다.
  if (!context.mounted || saved != true) return;
}

/// 삭제: 확인 Dialog 없이 바로 지우지 않습니다. 취소하면 API 요청도 없습니다.
Future<void> onDeletePressed(BuildContext context, RatingDto rating) async {
  final viewModel = context.read<MyRatingsViewModel>();
  await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막습니다.
    builder: (_) => _DeleteRatingDialog(
      onConfirm: () => viewModel.deleteRating(rating.ratingId),
    ),
  );
  // 결과(true)는 실제로 삭제까지 마쳤을 때만 옵니다. 목록 재조회는 deleteRating 안에서 합니다.
}

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 36, 18, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '평점을 삭제할까요?',
                style: TextStyle(
                  fontSize: 20,
                  height: 28 / 20,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '삭제한 평점은 복구할 수 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: _textSub,
                ),
              ),
              const SizedBox(height: 44),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      borderRadius: 8,
                      backgroundColor: _editBg,
                      foregroundColor: AppColors.violet,
                      disabledBackgroundColor: _editBg,
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: MovieLogButton(
                      label: '삭제',
                      borderRadius: 8,
                      isLoading: _isDeleting,
                      onPressed: _isDeleting ? null : _onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      // 403(본인 평점 아님)·404(없는 평점)를 서버 문구로 구분해서 안내합니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is DioException
                ? writeErrorMessage(error)
                : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.',
          ),
        ),
      );
    }
  }
}
