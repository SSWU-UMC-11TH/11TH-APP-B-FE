import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../view_models/movie_detail_view_model.dart';
import '../view_models/sign_up_view_model.dart' show SubmitStatus;
import '../widgets/movie_rating.dart';
import '../widgets/tmdb_poster_image.dart';

const _bg = Color(0xFFFAF9F5);
const _violet = Color(0xFF6750A4);
const _textMain = Color(0xFF1D1B20);
const _textSub = Color(0xFF494551);
const _chipBg = Color(0xFFE8DEF9);

/// 영화 DTO와 평점 등록 상태는 MovieDetailViewModel에서 읽습니다.
/// (MovieDetailLoader가 영화를 준비한 뒤 이 화면을 그립니다.)
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, this.genreNames = const []});

  /// 목록·홈에서 넘겨준 장르 이름. 직접 접근하면 비어 있을 수 있다.
  final List<String> genreNames;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  int? _myRating; // 이번에 등록한 평점 (없으면 null)

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
    final viewModel = context.read<MovieDetailViewModel>();
    int? savedScore;
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
          savedScore = score;
        },
      ),
    );

    // 저장 요청과 Snackbar 표시는 다른 비동기 경계라 mounted를 다시 확인합니다.
    if (!mounted || saved != true) return;

    setState(() => _myRating = savedScore);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieDetailViewModel>();
    final movie = viewModel.movie;
    final canRate = viewModel.memberId != null;
    final year = movie.releaseDate?.split('-').first; // 없으면 표시 안 함
    final score = movie.voteAverage / 2; // TMDB 10점 → 5점 만점

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
            TmdbPosterImage(
              posterPath: movie.posterPath,
              width: double.infinity,
              height: 350,
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
                  if (year != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$year년 개봉',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: _textSub,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: score,
                        itemCount: 5,
                        itemSize: 20,
                        itemBuilder: (_, _) =>
                            const Icon(Icons.star, color: _violet),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${score.toStringAsFixed(1)} · TMDB ${movie.voteAverage.toStringAsFixed(1)}/10',
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
                  if (widget.genreNames.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final genre in widget.genreNames)
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
                              genre,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4F378A),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
                  if (movie.overview.isEmpty)
                    // overview가 없으면 가운데에 안내 문구
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          '줄거리 정보가 없어요.',
                          style: TextStyle(fontSize: 16, color: _textSub),
                        ),
                      ),
                    )
                  else
                    Text(
                      movie.overview,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // memberId가 없으면 등록 버튼을 비활성화하고 회원가입으로 안내합니다.
              if (!canRate)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '학습용 회원가입을 완료해야 평점을 남길 수 있어요.',
                    style: TextStyle(fontSize: 13, color: _textSub),
                  ),
                ),
              Row(
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
                        onPressed: canRate ? _showRatingDialog : null,
                        icon: const Icon(Icons.star_border),
                        label: const Text('평점 남기기'),
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
            ],
          ),
        ),
      ),
    );
  }
}
