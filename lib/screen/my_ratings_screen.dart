import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../view_models/my_ratings_view_model.dart';
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
                onRetry: () => context.read<MyRatingsViewModel>().load(),
              ),
            MyRatingsLoadStatus.empty => const Center(
                child: Text(
                  '등록된 평점이 없습니다.',
                  style: TextStyle(color: Colors.black54),
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
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
            ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
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
        ],
      ),
    );
  }
}