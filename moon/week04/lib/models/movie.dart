class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.genres,
    required this.rating,
    required this.ratingCount,
    required this.duration,
    required this.imagePath,
    required this.synopsis, fontWeight,
  });

  final int id;
  final String title;
  final int year;
  final List<String> genres;
  final double rating;
  final int ratingCount;
  final int duration;
  final String imagePath;
  final String synopsis;
}