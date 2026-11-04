import 'package:flutter/material.dart';

class MovieEmpty extends StatelessWidget {
  const MovieEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '조건에 맞는 영화가 없습니다.',
      ),
    );
  }
}