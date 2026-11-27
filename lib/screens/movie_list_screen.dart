import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../services/genre_preference.dart';
import '../widgets/genre_chip_list.dart';
import '../widgets/genre_filter_sheet.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';

class MovieListInitialData {
  const MovieListInitialData({
    required this.movies,
    required this.selectedGenre,
  });

  final List<Movie> movies;
  final String selectedGenre;
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러', '로맨스'];

  final _movieService = FakeMovieService();
  final _genrePreference = GenrePreference();

  MovieLoadMode _loadMode = MovieLoadMode.success;
  String? _selectedGenre;
  Set<String> _filterGenres = {}; // 바텀시트에서 고른 장르 (비어 있으면 전체)
  late Future<MovieListInitialData> _initialDataFuture;

  @override
  void initState() {
    super.initState();
    _initialDataFuture = _loadInitialData();
  }

  Future<MovieListInitialData> _loadInitialData() async {
    try {
      final results = await Future.wait<Object>([
        _movieService.fetchMovies(mode: _loadMode),
        _genrePreference.read(),
      ]);
      final saved = results[1] as String;
      return MovieListInitialData(
        movies: results[0] as List<Movie>,
        selectedGenre: _genres.contains(saved) ? saved : '전체',
      );
    } on MovieLoadException {
      rethrow;
    } finally {
      debugPrint('영화 목록 초기 데이터 로딩 종료');
    }
  }

  void _reload({required MovieLoadMode mode}) {
    setState(() {
      _loadMode = mode;
      _initialDataFuture = _loadInitialData();
    });
  }

  void _retry() => _reload(mode: MovieLoadMode.success);

  Future<void> _onGenreSelected(String genre) async {
    setState(() => _selectedGenre = genre);
    await _genrePreference.save(genre);
  }

  Future<void> _openFilterSheet() async {
    final result = await showGenreFilterSheet(context, initial: _filterGenres);
    if (!mounted || result == null) return;
    setState(() => _filterGenres = result);
  }

  List<Movie> _applyFilters(List<Movie> movies, String chipGenre) {
    return movies.where((m) {
      final chipOk = chipGenre == '전체' || m.genre == chipGenre;
      final sheetOk = _filterGenres.isEmpty || _filterGenres.contains(m.genre);
      return chipOk && sheetOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '영화',
          style: TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6750A4),
          ),
        ),
        actions: [
          // 4주차 테스트용 상태 전환 메뉴 (필터 아이콘과 헷갈리지 않게 아이콘 변경)
          PopupMenuButton<MovieLoadMode>(
            icon: const Icon(Icons.bug_report_outlined),
            onSelected: (mode) => _reload(mode: mode),
            itemBuilder: (_) => const [
              PopupMenuItem(value: MovieLoadMode.success, child: Text('성공')),
              PopupMenuItem(value: MovieLoadMode.empty, child: Text('빈 목록')),
              PopupMenuItem(value: MovieLoadMode.failure, child: Text('실패')),
            ],
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<MovieListInitialData>(
        future: _initialDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MovieListLoading();
          }
          if (snapshot.hasError) {
            return MovieListError(onRetry: _retry);
          }

          final data = snapshot.data!;
          final chipGenre = _selectedGenre ?? data.selectedGenre;
          final filtered = _applyFilters(data.movies, chipGenre);

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GenreChipList(
                      genres: _genres,
                      selectedGenre: chipGenre,
                      onGenreSelected: _onGenreSelected,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: _filterGenres.isEmpty
                          ? const Color(0xFF1D1B20)
                          : const Color(0xFF6750A4),
                    ),
                    onPressed: _openFilterSheet,
                  ),
                ],
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const MovieListEmpty()
                    : MovieGrid(movies: filtered),
              ),
            ],
          );
        },
      ),
    );
  }
}
