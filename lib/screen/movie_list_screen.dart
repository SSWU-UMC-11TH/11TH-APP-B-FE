import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/status/movie_empty_widget.dart';
import '../widgets/status/movie_error_widget.dart';
import '../widgets/status/movie_loading_widget.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FakeMovieService _movieService = FakeMovieService();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const String _genreKey = 'selected_genre';
  
  String selectedGenre = '전체';
  final List<String> genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];

  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    // 1. build 안이 아닌 initState에서 Future 생성 (저장된 장르 불러온 뒤 fetch)
    _moviesFuture = _initAndFetchMovies();
  }

  // 앱 실행 시 저장된 장르 복원 후 비동기 목록 조회
  Future<List<Movie>> _initAndFetchMovies() async {
    final savedGenre = await _prefs.getString(_genreKey);
    if (savedGenre != null && genres.contains(savedGenre)) {
      selectedGenre = savedGenre;
    }
    return _movieService.fetchMovies(selectedGenre: selectedGenre);
  }

  // 재시도 및 장르 변경 시 새로운 Future 생성
  void _refetchMovies() {
    setState(() {
      _moviesFuture = _movieService.fetchMovies(selectedGenre: selectedGenre);
    });
  }

  // 장르 선택 시 SharedPreferencesAsync 저장 및 화면 갱신
  Future<void> _onGenreSelected(String genre) async {
    if (selectedGenre == genre) return;

    setState(() {
      selectedGenre = genre;
    });

    await _prefs.setString(_genreKey, genre);

    // await 실행 후 mounted 검증 필수
    if (!mounted) return;
    _refetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영화')),
      body: Column(
        children: [
          // 장르 선택 Chip 목록 (기존 ListView.separated UI 유지)
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = genre == selectedGenre;
                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _onGenreSelected(genre);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 비동기 4가지 상태 처리 (FutureBuilder)
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                // 1. Loading 상태 (최소 800ms 이상 노출)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const MovieLoadingWidget();
                }

                // 2. Error 상태 (예외 문구 직접 노출 X, 재시도 버튼 제공)
                if (snapshot.hasError) {
                  return MovieErrorWidget(onRetry: _refetchMovies);
                }

                final filteredMovies = snapshot.data ?? [];

                // 3. Empty 상태
                if (filteredMovies.isEmpty) {
                  return const MovieEmptyWidget();
                }

                // 4. Success 상태 (기존 GridView + MovieCard 구조 100% 유지)
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movie: filteredMovies[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}