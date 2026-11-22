import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_view_model.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  Future<void> _onLogoutPressed(BuildContext context) async {
    final auth = context.read<AuthViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // 토큰과 member를 지우고 signedOut → Router가 /login으로 이동합니다.
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    // member가 바뀌면(프로필 수정) 다시 그려지도록 구독합니다.
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;

    final String nickname;
    final String email;
    if (member != null) {
      nickname = member.nickname;
      email = member.email;
    } else if (auth.memberStatus == MemberLoadStatus.error) {
      nickname = '내 정보를 불러오지 못했어요';
      email = '';
    } else {
      nickname = '불러오는 중...';
      email = '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: auth.storageCleanupInProgress
                ? null
                : () => _onLogoutPressed(context),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Color(0xFF6750A4)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. 프로필 이미지 & 이름 (GET me로 받은 내 정보)
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              nickname,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                email,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
            if (auth.memberStatus == MemberLoadStatus.error) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => auth.loadMember(force: true),
                child: const Text('다시 시도'),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              // 내 정보가 있을 때만 프로필 수정 화면으로 이동할 수 있습니다.
              onPressed: member == null
                  ? null
                  : () => context.push('/my/profile/edit'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('프로필 수정'),
            ),
            const SizedBox(height: 24),

            // 2. 활동 통계 요약 (기존 디자인 예시)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F4FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildStatItem('본 영화', '342')),
                  Expanded(child: _buildStatItem('평점', '4.2')),
                  Expanded(child: _buildStatItem('즐겨찾기', '58')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 내가 등록한 평점 진입 행
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/my/ratings'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0DCEB)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        '내가 등록한 평점',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF6750A4)),
                  ],
                ),
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
