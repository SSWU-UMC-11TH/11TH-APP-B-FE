import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../data/services/rating_api_service.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/status/movie_loading_widget.dart';
import '../widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '내가 등록한 평점',
          style: TextStyle(
            color: Color(0xFF6B4EFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // bottomNavigationBar는 전달하지 않습니다.
      body: Consumer<MyRatingsViewModel>(
        builder: (context, vm, child) {
          return switch (vm.status) {
            MyRatingsLoadStatus.idle ||
            MyRatingsLoadStatus.loading =>
              const MovieLoadingWidget(),
            MyRatingsLoadStatus.error => _ErrorView(
                message: vm.message ?? '평점을 불러오지 못했습니다.',
                retryLabel: '다시 시도',
                onRetry: () => context.read<MyRatingsViewModel>().load(),
              ),
            MyRatingsLoadStatus.empty => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '이번 로그인에서 등록한 평점이 없습니다.\n영화 상세에서 평점을 남겨 보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                ),
              ),
            MyRatingsLoadStatus.success => _RatingList(
                entries: vm.ratings,
                notice: vm.message,
              ),
          };
        },
      ),
    );
  }
}

/// 수정: 기존 score·comment를 채운 RatingDialog를 다시 엽니다.
Future<void> onEditPressed(BuildContext context, RatingDto rating) async {
  // 저장 후 목록이 다시 그려지면 카드의 context가 사라질 수 있으므로 먼저 잡아 둡니다.
  final viewModel = context.read<MyRatingsViewModel>();
  final messenger = ScaffoldMessenger.of(context);

  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
    builder: (_) => RatingDialog(
      title: '평점을 수정해 주세요',
      initialScore: rating.score,
      initialComment: rating.comment, // null이면 TextField가 빈 칸으로 시작합니다.
      onSubmit: (score, comment) => viewModel.updateRating(
        ratingId: rating.ratingId,
        score: score,
        comment: comment,
      ),
    ),
  );

  if (saved != true) return;
  messenger.showSnackBar(
    const SnackBar(content: Text('평점을 수정했습니다.')),
  );
}

/// 삭제: 확인 Dialog를 거치고, 삭제 요청 중에는 Dialog를 유지합니다.
Future<void> onDeletePressed(BuildContext context, RatingDto rating) async {
  final viewModel = context.read<MyRatingsViewModel>();
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막습니다.
    builder: (_) => _DeleteRatingDialog(
      onConfirm: () => viewModel.deleteRating(rating.ratingId),
    ),
  );

  // confirmed는 실제로 삭제까지 마쳤을 때만 true입니다. 취소하면 API 요청이 없습니다.
  if (confirmed != true) return;
  messenger.showSnackBar(
    const SnackBar(content: Text('평점을 삭제했습니다.')),
  );
}

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '평점을 삭제할까요?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '삭제한 평점은 복구할 수 없습니다.',
                style: TextStyle(color: Colors.black54),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MovieLogButton(
                      label: '삭제',
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
    setState(() {
      _isDeleting = true;
      _errorText = null;
    });
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      final message = error is RatingActionException
          ? error.message
          : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      setState(() {
        _isDeleting = false;
        _errorText = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

class _RatingList extends StatelessWidget {
  const _RatingList({required this.entries, this.notice});

  final List<RatingWithMovie> entries;
  final String? notice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // v7에는 토큰 기반 "내 평점 목록 GET"이 없어 현재 세션에서 등록한 평점만 보여줍니다.
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1ECFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '이번 로그인 중에 등록한 평점이에요. 앱을 다시 시작하면 목록이 비워질 수 있어요.',
            style: TextStyle(fontSize: 12),
          ),
        ),
        if (notice != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(notice!, style: const TextStyle(fontSize: 12)),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _RatingCard(entry: entries[index]),
          ),
        ),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}.$m.$day';
  }

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie;
    final comment = rating.comment;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0DCEB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: movie != null
                ? TmdbPosterImage(
                    posterPath: movie.posterPath,
                    width: 64,
                    height: 96,
                  )
                : Container(
                    width: 64,
                    height: 96,
                    color: const Color(0xFFD8D2E0),
                    alignment: Alignment.center,
                    child: const Text(
                      '포스터\n정보 없음',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? '영화 #${rating.movieId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '별점 ${rating.score} / 5',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4EFF),
                  ),
                ),
                // comment가 null이면 표시하지 않습니다.
                if (comment != null && comment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(comment, style: const TextStyle(fontSize: 13)),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDate(rating.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          // 카드 오른쪽: 개별 수정·삭제 버튼 (현재 세션에서 본인이 등록한 평점입니다)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '수정',
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF6B4EFF)),
                onPressed: () => onEditPressed(context, rating),
              ),
              IconButton(
                tooltip: '삭제',
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => onDeletePressed(context, rating),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
