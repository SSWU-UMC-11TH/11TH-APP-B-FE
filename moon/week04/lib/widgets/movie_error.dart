import 'package:flutter/material.dart';

class MovieError extends StatelessWidget {
  const MovieError({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [

          const Text(
            '영화를 불러오지 못했습니다.',
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: onRetry,
            child: const Text(
              '다시 시도',
            ),
          ),

        ],
      ),
    );
  }
}