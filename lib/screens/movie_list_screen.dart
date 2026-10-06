import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/genre_chip_list.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final List<String> _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];
  String _selectedGenre = '전체';

  @override
  Widget build(BuildContext context) {
    // 장르 필터링 로직
    final filteredMovies = _selectedGenre == '전체'
        ? mockMovies
        : mockMovies.where((m) => m.genre == _selectedGenre).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '영화',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // 장르 Horizontal ListView
          GenreChipList(
            genres: _genres,
            selectedGenre: _selectedGenre,
            onGenreSelected: (genre) {
              setState(() {
                _selectedGenre = genre;
              });
            },
          ),
          const SizedBox(height: 16),

          // 영화 목록 GridView
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                itemCount: filteredMovies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  return MovieCard(movie: filteredMovies[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
