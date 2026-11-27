import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/services/rating_api_service.dart';
import '../view_models/movie_detail_view_model.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;

  Future<void> _onRatePressed() async {
    // Dialog가 떠 있는 동안 화면이 다시 그려져도 같은 ViewModel을 쓰도록 미리 잡아 둡니다.
    final viewModel = context.read<MovieDetailViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            // Dialog가 서버 message를 그대로 보여주고 입력값을 유지합니다.
            throw RatingActionException(
              viewModel.submitMessage ?? '저장에 실패했습니다.',
            );
          }
        },
      ),
    );

    // 저장 요청과 Snackbar 표시는 서로 다른 비동기 경계이므로 mounted를 다시 확인합니다.
    if (!mounted) return;

    if (saved == true) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.'),
        ),
      );
    } else if (viewModel.submitStatus == SubmitStatus.error) {
      // 실패 후 사용자가 Dialog를 취소한 경우
      messenger.showSnackBar(
        SnackBar(
          content: Text('평점을 등록하지 못했습니다. ${viewModel.submitMessage ?? ''}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieDetailViewModel>();
    final movie = viewModel.movie;
    final score = movie.voteAverage / 2;
    final date = movie.releaseDate;
    final year =
        (date == null || date.isEmpty) ? '개봉일 미정' : date.split('-').first;

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
            Text(year, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            // 읽기 전용 별점 표시 (TMDB 평균)
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
                // 평점 남기기: 학습용 회원가입(memberId)이 없으면 비활성화
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.canRate &&
                            viewModel.submitStatus != SubmitStatus.submitting
                        ? _onRatePressed
                        : null,
                    icon: const Icon(Icons.star),
                    label: const Text('평점 남기기'),
                  ),
                ),
              ],
            ),
            if (!viewModel.canRate) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '평점을 남기려면 학습용 회원가입이 필요합니다.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('회원가입'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
