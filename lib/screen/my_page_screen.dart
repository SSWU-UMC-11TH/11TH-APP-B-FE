import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. 프로필 이미지 & 이름
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              '무비러버',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              '매주 주말엔 영화관으로 출근하는 프로 관람객, 좋은 영화를 보고 기록하는 것을 좋아합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('프로필 수정'),
            ),
            const SizedBox(height: 24),

            // 2. 활동 통계 요약 (본 영화 / 평점 / 즐겨찾기)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F4FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('본 영화', '342'),
                  Container(height: 30, width: 1, color: Colors.grey[300]),
                  _buildStatItem('평점', '4.2'),
                  Container(height: 30, width: 1, color: Colors.grey[300]),
                  _buildStatItem('즐겨찾기', '58'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 3. 선호하는 장르
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '선호하는 장르',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: const [
                      Chip(
                        label: Text('드라마'),
                        backgroundColor: Color(0xFFECE6F0),
                        side: BorderSide.none,
                      ),
                      Chip(
                        label: Text('SF'),
                        backgroundColor: Color(0xFFECE6F0),
                        side: BorderSide.none,
                      ),
                      Chip(
                        label: Text('애니메이션'),
                        backgroundColor: Color(0xFFECE6F0),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
          ),
        ),
      ],
    );
  }
}
