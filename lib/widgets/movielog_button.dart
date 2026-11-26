import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 여러 화면이 같이 쓰는 공용 버튼.
/// 상태(통신 중인지, 누를 수 있는지, 너비)는 화면이 전달하고, 버튼은 표시만 한다.
/// 7주차: Dialog의 취소·삭제 버튼처럼 색과 모서리가 다른 버튼도 같은 위젯으로 그리도록
/// 색·모서리·높이를 선택 값으로 받는다. (넘기지 않으면 6주차와 같은 모양)
class MovieLogButton extends StatelessWidget {
  const MovieLogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 44,
    this.backgroundColor = AppColors.violet,
    this.foregroundColor = AppColors.white,
    this.disabledBackgroundColor = AppColors.gray,
    this.borderRadius = 12,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;

  /// 로딩이 아닌 비활성 상태의 배경색. 로딩 중에는 항상 회색입니다.
  final Color disabledBackgroundColor;
  final double borderRadius;

  bool get _disabled => isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: _disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: isLoading
              ? AppColors.gray
              : disabledBackgroundColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}
