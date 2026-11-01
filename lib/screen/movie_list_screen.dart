import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedGenre = '전체';
  final List<String> genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];

  @override
  Widget build(BuildContext context) {
    final filteredMovies = selectedGenre == '전체'
        ? mockMovies
        : mockMovies.where((m) => m.genre == selectedGenre).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('영화')),
      body: Column(
        children: [
          // 장르 เลือก Chip 목록
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
                      setState(() {
                        selectedGenre = genre;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // GridView 기반 영화 목록
          Expanded(
            child: GridView.builder(
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
            ),
          ),
        ],
      ),
    );
  }
}
