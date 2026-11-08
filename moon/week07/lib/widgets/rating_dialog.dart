import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/services/rating_api_service.dart';
import '../theme/app_colors.dart';
import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.movieId,
    this.initialRating = 0,
    this.initialComment,
    this.onSubmit,
    this.isEditing = false,
  });

  final int? movieId;
  final double initialRating;
  final String? initialComment;
  final Future<void> Function(int score, String? comment)? onSubmit;
  final bool isEditing;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double rating;
  late TextEditingController _commentController;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    rating = widget.initialRating;
    _commentController = TextEditingController(
      text: widget.initialComment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || rating < 1 || rating > 5) return;

    if (rating != rating.roundToDouble()) {
      setState(() {
        _errorMessage = '별점은 정수 단위로 선택해주세요.';
      });
      return;
    }

    final score = rating.toInt();
    final trimmedComment = _commentController.text.trim();
    final String? comment = trimmedComment.isEmpty ? null : trimmedComment;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(score, comment);
      } else {
        debugPrint('[RatingDialog] movieId=${widget.movieId}, score=$score');
      }

      if (!mounted) return;

      Navigator.of(context).pop(rating);
    } on DioException catch (error) {
      if (!mounted) return;

      debugPrint('[RatingDialog] API 오류: HTTP ${error.response?.statusCode}');

      setState(() {
        _errorMessage = writeErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('[RatingDialog] 저장 실패: ${error.runtimeType}');

      setState(() {
        _errorMessage = '평점 저장에 실패했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isEditing ? '평점을 수정하시겠어요?' : '영화는 어떠셨나요?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '별점을 선택해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                MovieRatingInput(
                  rating: rating,
                  enabled: !_isSubmitting,
                  onChanged: (value) {
                    setState(() {
                      rating = value;
                      _errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  rating == 0 ? '평점을 선택해주세요' : '${rating.toInt()}점',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _commentController,
                  enabled: !_isSubmitting,
                  maxLength: 500,
                  maxLines: 3,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: '영화에 대한 감상을 남겨주세요 (선택)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: rating == 0 || _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.disabledButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            widget.isEditing ? '수정하기' : '확인',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
