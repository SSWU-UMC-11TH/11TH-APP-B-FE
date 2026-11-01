import 'package:flutter/material.dart';

class MovieEmptyWidget extends StatelessWidget {
  const MovieEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('해당 장르의 영화가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}