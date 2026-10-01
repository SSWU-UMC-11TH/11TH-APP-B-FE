import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../services/fake_movie_service.dart';
import '../services/preference_service.dart';

import '../widgets/movie_loading.dart';
import '../widgets/movie_empty.dart';
import '../widgets/movie_error.dart';



class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final List<String> genres = [
    '전체',
    '드라마',
    'SF',
    '애니메이션',
    '스릴러',
    '로맨스',
    '액션',
  ];

  final FakeMovieService movieService =
      const FakeMovieService();

  late Future<List<Movie>> _moviesFuture;

  final PreferenceService preferenceService =
     PreferenceService();

  String selectedGenre = '전체';


  @override
void initState() {
  super.initState();

  _moviesFuture = movieService.fetchMovies();

  _loadSelectedGenre();
}


  void _retry() {
    setState(() {
      _moviesFuture = movieService.fetchMovies();
    });
  }


Future<void> _loadSelectedGenre() async {
  final savedGenre =
      await preferenceService.loadGenre();

  if (savedGenre != null &&
      genres.contains(savedGenre)) {
    setState(() {
      selectedGenre = savedGenre;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 제목 + 검색
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  '영화',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),

              ],
            ),


            const SizedBox(height: 12),


            // 장르 선택
            SizedBox(
              height: 36,

              child: ListView.separated(
                scrollDirection: Axis.horizontal,

                itemCount: genres.length,

                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),

                itemBuilder: (context, index) {

                  final genre = genres[index];

                  final isSelected =
                      selectedGenre == genre;


                  return ChoiceChip(

                    label: Text(genre),

                    selected: isSelected,

                    showCheckmark: false,


                    onSelected: (_) async {

                      setState(() {
                        selectedGenre = genre;
                      });

                     await preferenceService.saveGenre(genre);

                    },


                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,

                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),


                    selectedColor:
                        AppColors.primary,


                    backgroundColor:
                        AppColors.chipBackground,


                    side: BorderSide.none,


                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                  );

                },
              ),
            ),


            const SizedBox(height: 18),



            Expanded(

              child: FutureBuilder<List<Movie>>(

                future: _moviesFuture,


                builder: (context, snapshot) {


                  // Loading
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {

                    
                  return const MovieLoading();
                  }



                  // Error
                  if (snapshot.hasError) {

                    return MovieError(
                      onRetry: _retry,
                    );

                  }



                  final List<Movie> movies =
                      snapshot.data ?? [];



                  final filteredMovies =
                      selectedGenre == '전체'
                      ? movies
                      : movies
                          .where(
                            (movie) =>
                                movie.genres
                                    .contains(
                                      selectedGenre,
                                    ),
                          )
                          .toList();



                  // Empty
                  if (filteredMovies.isEmpty) {

                    return const MovieEmpty();

                  }




                  // Success
                  return GridView.builder(

                    itemCount:
                        filteredMovies.length,


                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount: 2,

                      crossAxisSpacing: 12,

                      mainAxisSpacing: 18,

                      childAspectRatio: 0.58,

                    ),


                    itemBuilder:
                        (context, index) {


                      final movie =
                          filteredMovies[index];


                      return _MovieGridItem(

                        movie: movie,


                        onTap: () {

                          context.push(
                            '/movies/${movie.id}',
                          );

                        },

                      );

                    },

                  );

                },

              ),

            ),

          ],
        ),
      ),
    );
  }
}





class _MovieGridItem extends StatelessWidget {

  const _MovieGridItem({

    required this.movie,

    required this.onTap,

  });


  final Movie movie;

  final VoidCallback onTap;



  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      behavior: HitTestBehavior.opaque,


      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,


        children: [


          Expanded(

            child: ClipRRect(

              borderRadius:
                  BorderRadius.circular(8),


              child: Stack(

                fit: StackFit.expand,


                children: [


                  Image.asset(

                    movie.imagePath,

                    fit: BoxFit.cover,

                  ),



                  Positioned(

                    top: 8,

                    right: 8,


                    child: Container(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),


                      decoration:
                          BoxDecoration(

                        color:
                            Colors.black.withValues(
                              alpha: 0.7,
                            ),

                        borderRadius:
                            BorderRadius.circular(12),

                      ),


                      child: Row(

                        mainAxisSize:
                            MainAxisSize.min,


                        children: [

                          const Icon(

                            Icons.star,

                            size: 12,

                            color: Colors.white,

                          ),


                          const SizedBox(width: 3),


                          Text(

                            movie.rating
                                .toStringAsFixed(1),


                            style:
                                const TextStyle(

                              fontSize: 10,

                              color: Colors.white,

                              fontWeight:
                                  FontWeight.w600,

                            ),

                          ),

                        ],

                      ),

                    ),

                  ),

                ],

              ),

            ),

          ),



          const SizedBox(height: 8),



          Text(

            movie.title,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,


            style:
                const TextStyle(

              fontSize: 14,

              fontWeight:
                  FontWeight.w700,

              color:
                  AppColors.textPrimary,

            ),

          ),



          const SizedBox(height: 3),



          Text(

            '${movie.year} · ${movie.genres.join(' · ')}',

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,


            style:
                const TextStyle(

              fontSize: 11,

              color: Colors.grey,

            ),

          ),


        ],

      ),

    );

  }

}