import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../theme/app_colors.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: RatingBar.builder(
        initialRating: rating,
        minRating: 1,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: 40,
        unratedColor: AppColors.fieldBorder,
        itemBuilder: (context, index) {
          return const Icon(
            Icons.star,
            color: AppColors.primary,
          );
        },
        onRatingUpdate: onChanged,
      ),
    );
  }
}
