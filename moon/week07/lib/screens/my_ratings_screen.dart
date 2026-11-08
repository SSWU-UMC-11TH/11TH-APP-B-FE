import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../data/services/rating_api_service.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/rating_dialog.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editRating(
    BuildContext context,
    MyRatingsViewModel viewModel,
    RatingWithMovie item,
  ) async {
    if (viewModel.isMutating) return;

    final rating = item.rating;
    bool refreshed = false;

    final result = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        movieId: rating.movieId,
        isEditing: true,
        initialRating: rating.score.toDouble(),
        initialComment: rating.comment,
        onSubmit: (score, comment) async {
          refreshed = await viewModel.updateRating(
            ratingId: rating.ratingId,
            score: score,
            comment: comment,
          );
        },
      ),
    );

    if (!context.mounted || result == null) return;

    _showMessage(
      context,
      refreshed ? '평점을 수정했습니다.' : '평점은 수정됐지만 목록을 다시 불러오지 못했습니다.',
    );
  }

  Future<void> _deleteRating(
    BuildContext context,
    MyRatingsViewModel viewModel,
    RatingWithMovie item,
  ) async {
    if (viewModel.isMutating) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('평점 삭제'),
        content: const Text('이 평점을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted || viewModel.isMutating) {
      return;
    }

    try {
      final refreshed = await viewModel.deleteRating(item.rating.ratingId);

      if (!context.mounted) return;

      _showMessage(
        context,
        refreshed ? '평점을 삭제했습니다.' : '평점은 삭제됐지만 목록을 다시 불러오지 못했습니다.',
      );
    } on DioException catch (error) {
      if (!context.mounted) return;
      _showMessage(context, writeErrorMessage(error));
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, '평점 삭제에 실패했습니다. 다시 시도해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyRatingsViewModel>();

    return PopScope(
      canPop: !viewModel.isMutating,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: viewModel.isMutating ? null : () => context.pop(),
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
      ),
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
                  onPressed: viewModel.isMutating
                      ? null
                      : () => viewModel.loadRatings(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        );

      case MyRatingsLoadStatus.success:
        return RefreshIndicator(
          onRefresh: viewModel.isMutating
              ? () async {}
              : () => viewModel.loadRatings(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.ratings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = viewModel.ratings[index];

              return _RatingCard(
                item: item,
                enabled: !viewModel.isMutating,
                onEdit: () => _editRating(context, viewModel, item),
                onDelete: () => _deleteRating(context, viewModel, item),
              );
            },
          ),
        );
    }
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.item,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
  });

  final RatingWithMovie item;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: enabled ? onEdit : null,
                      child: const Text('수정'),
                    ),
                    OutlinedButton(
                      onPressed: enabled ? onDelete : null,
                      child: const Text('삭제'),
                    ),
                  ],
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
