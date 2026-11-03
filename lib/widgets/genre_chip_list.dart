import 'package:flutter/material.dart';

import '../data/models/tmdb_genre_dto.dart';

/// 맨 앞 "전체"(id: null) + Genre API로 받은 장르들을 칩으로 보여 준다.
class GenreChipList extends StatelessWidget {
  const GenreChipList({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.onGenreSelected,
    this.enabled = true,
  });

  final List<TmdbGenreDto> genres;
  final int? selectedGenreId;
  final ValueChanged<int?> onGenreSelected;
  final bool enabled; // 로딩 중에는 false → 탭이 무시된다.

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: genres.length + 1, // +1은 "전체"
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final int? genreId = index == 0 ? null : genres[index - 1].id;
            final label = index == 0 ? '전체' : genres[index - 1].name;
            final isSelected = genreId == selectedGenreId;

            return GestureDetector(
              onTap: enabled ? () => onGenreSelected(genreId) : null,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6750A4)
                      : const Color(0xFFE6E0E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF1D1B20),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
