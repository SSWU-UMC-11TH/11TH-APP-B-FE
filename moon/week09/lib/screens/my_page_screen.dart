import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/profile_header.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            auth.memberStatus == MemberLoadStatus.loading ||
                (member == null && auth.memberStatus == MemberLoadStatus.idle)
            ? const Center(child: CircularProgressIndicator())
            : auth.memberStatus == MemberLoadStatus.error || member == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('내 정보를 불러오지 못했어요.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthViewModel>().loadMember(force: true);
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '내 프로필',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        TextButton(
                          onPressed: auth.storageCleanupInProgress
                              ? null
                              : () {
                                  context.read<AuthViewModel>().logout();
                                },
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    const ProfileHeader(),
                    const SizedBox(height: 44),
                    const Row(
                      children: [
                        Expanded(
                          child: _StatCard(label: '본 영화', value: '342'),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(label: '평점', value: '4.2'),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(label: '즐겨찾기', value: '58'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const _ActivityCard(
                      title: '내가 등록한 평점',
                      route: '/mypage/ratings',
                    ),
                    const SizedBox(height: 10),
                    const _ActivityCard(
                      title: '내 즐겨찾기',
                      route: '/mypage/favorites',
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '선호하는 장르',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _GenreChip(label: '공포'),
                        _GenreChip(label: '코미디'),
                        _GenreChip(label: '스릴러'),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.title, required this.route});

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightviolet, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.statBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightviolet),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightviolet,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
