import 'package:flutter/material.dart';

class MovieLoadingWidget extends StatelessWidget {
  const MovieLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.deepPurple),
          SizedBox(height: 16),
          Text('영화 목록을 불러오는 중입니다...'),
        ],
      ),
    );
  }
}