import 'package:flutter/material.dart';

class MovieLoading extends StatelessWidget {
  const MovieLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}