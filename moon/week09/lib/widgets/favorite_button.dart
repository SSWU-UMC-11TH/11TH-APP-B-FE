import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../view_models/favorite_detail_view_model.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  Future<void> _toggle(BuildContext context, FavoriteDetailViewModel vm) async {
    final previous = vm.isFavorite;

    await vm.toggle();

    if (!context.mounted) return;

    final message = vm.errorMessage;

    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    if (previous == vm.isFavorite) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(vm.isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteDetailViewModel>(
      builder: (context, vm, _) {
        final busy = vm.isLoading || vm.isSaving;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.fieldBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: busy
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: vm.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 등록',
                      onPressed: !vm.hasLoadedStatus
                          ? vm.load
                          : () => _toggle(context, vm),
                      icon: Icon(
                        !vm.hasLoadedStatus
                            ? Icons.refresh
                            : vm.isFavorite
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
            ),
            const SizedBox(height: 5),
            const Text(
              '즐겨찾기',
              style: TextStyle(fontSize: 11, color: AppColors.primary),
            ),
          ],
        );
      },
    );
  }
}
