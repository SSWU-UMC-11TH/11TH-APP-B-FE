import 'package:flutter/material.dart';

import '../data/models/rating_request.dart';
import '../data/services/rating_api_service.dart';
import 'movie_rating_input.dart';
import 'movielog_button.dart';

/// 평점 등록·수정 공용 Dialog
///
/// 저장 로직은 [onSubmit]으로 받아 Dialog 안에서 실행합니다.
/// - onSubmit이 예외 없이 끝나면 true를 반환하며 닫힙니다.
/// - 취소하면 onSubmit을 호출하지 않고 false를 반환합니다. (API 요청 없음)
/// - 실패하면 Dialog를 유지하고 입력값을 보존한 채 오류 문구를 보여줍니다.
///
/// 호출부에서는 반드시 showDialog(barrierDismissible: false)와 함께 씁니다.
/// (PopScope는 뒤로가기만 막고, 바깥 탭은 barrierDismissible이 막습니다)
class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.title = '평점을 남겨주세요',
    this.initialScore = 0,
    this.initialComment,
    required this.onSubmit,
  });

  final String title;
  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score = widget.initialScore;
  // build()마다 새로 만들면 별점 선택 시 입력 중인 코멘트가 사라지므로 한 번만 만듭니다.
  late final _commentController =
      TextEditingController(text: widget.initialComment ?? '');
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting, // 저장 중 뒤로가기로 닫히는 것을 막습니다.
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              MovieRatingInput(
                rating: _score.toDouble(),
                enabled: !_isSubmitting,
                onChanged: (value) => setState(
                  () => _score = validateServerScore(value),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 3,
                maxLength: 500,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  hintText: '코멘트를 남겨보세요 (선택)',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    // 별점을 선택해야(_score > 0) 확인 버튼이 활성화됩니다.
                    child: MovieLogButton(
                      label: '확인',
                      isLoading: _isSubmitting,
                      onPressed:
                          _score > 0 && !_isSubmitting ? _onConfirm : null,
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
    if (_isSubmitting) return; // 연속 탭 방지
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
      // 빈 문자열은 null로 바꿔 요청합니다.
      await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      // 실패해도 로딩을 반드시 해제해야 다시 시도할 수 있습니다.
      setState(() {
        _isSubmitting = false;
        _errorText = error is RatingActionException
            ? error.message
            : '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }
}
