import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../data/models/rating_request.dart';
import '../data/services/rating_api_service.dart';
import '../theme/app_colors.dart';
import 'movielog_button.dart';

// Figma W7-UI-01 평점 Dialog 기준 값
const _textMain = Color(0xFF1D1B20);
const _labelColor = Color(0xFF49454F);
const _hintColor = Color(0xFF79747E);
const _fieldFill = Color(0xFFF8F5FC);
const _fieldBorder = Color(0xFFD9D2E3);
const _cancelBg = Color(0xFFEEE9F8);

/// 7주차 서버 연동 모드: 별 한 개 단위(1~5 정수)만 선택합니다.
class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      initialRating: rating,
      minRating: 1,
      allowHalfRating: false,
      ignoreGestures: !enabled,
      itemCount: 5,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
      // 선택한 별은 채운 별, 선택하지 않은 별은 테두리 별 (Figma)
      ratingWidget: RatingWidget(
        full: const Icon(Icons.star, color: AppColors.violet),
        half: const Icon(Icons.star_half, color: AppColors.violet),
        empty: const Icon(Icons.star_border, color: AppColors.violet),
      ),
      onRatingUpdate: onChanged,
    );
  }
}

/// 평점 등록·수정 Dialog. 저장 로직은 onSubmit으로 받아 Dialog 안에서 실행합니다.
/// onSubmit이 예외 없이 끝나면 true, 취소하면 onSubmit을 부르지 않고 false를 반환합니다.
class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.initialScore = 0,
    this.initialComment,
    required this.onSubmit,
  });

  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score = widget.initialScore;
  late final _commentController = TextEditingController(
    text: widget.initialComment ?? '',
  );
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    // 저장 중에는 뒤로가기로 닫히지 않습니다. (바깥 탭은 barrierDismissible: false)
    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 36, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '평점을 남겨주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: MovieRatingInput(
                  rating: _score.toDouble(),
                  enabled: !_isSubmitting,
                  onChanged: (value) =>
                      setState(() => _score = validateServerScore(value)),
                ),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '코멘트 (선택, 최대 500자)',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: _labelColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                minLines: 3,
                maxLines: 3,
                maxLength: 500,
                enabled: !_isSubmitting,
                style: const TextStyle(fontSize: 14, color: _textMain),
                decoration: InputDecoration(
                  hintText: '이 영화의 인상적인 장면은...',
                  hintStyle: const TextStyle(fontSize: 14, color: _hintColor),
                  counterText: '', // 글자 수 표시는 숨기고 500자 제한만 둡니다.
                  filled: true,
                  fillColor: _fieldFill,
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: border(_fieldBorder),
                  disabledBorder: border(_fieldBorder),
                  focusedBorder: border(AppColors.violet),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: const TextStyle(fontSize: 13, color: AppColors.error),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      height: 46,
                      borderRadius: 23,
                      backgroundColor: _cancelBg,
                      foregroundColor: AppColors.violet,
                      disabledBackgroundColor: _cancelBg,
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MovieLogButton(
                      label: '확인',
                      height: 46,
                      borderRadius: 23,
                      disabledBackgroundColor: AppColors.disabledButton,
                      isLoading: _isSubmitting,
                      // 별점을 선택해야만 확인 버튼이 활성화됩니다.
                      onPressed: _score > 0 && !_isSubmitting
                          ? _onConfirm
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final trimmed = _commentController.text.trim();
    if (trimmed.length > 500) {
      setState(() {
        _isSubmitting = false;
        _errorText = '코멘트는 500자 이하로 입력해 주세요.';
      });
      return;
    }
    try {
      await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      // 실패해도 Dialog를 닫지 않으므로 입력한 별점·코멘트가 그대로 남습니다.
      setState(() {
        _isSubmitting = false;
        _errorText = switch (error) {
          DioException() => writeErrorMessage(error), // 400/403/404/409 서버 문구
          StateError(:final message) => message,
          _ => '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.',
        };
      });
    }
  }
}
